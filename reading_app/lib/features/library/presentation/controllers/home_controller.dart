import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/ai_access.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reader_dashboard.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/get_profiles.dart';

class OnboardingProfileDraft {
  final String name;
  final String ageGroup;
  final String readingMood;
  final List<String> favoriteCategories;

  const OnboardingProfileDraft({
    required this.name,
    required this.ageGroup,
    required this.readingMood,
    required this.favoriteCategories,
  });
}

class HomeController extends ChangeNotifier {
  final LibraryRepository repository;
  final GetBooks getBooks;
  final GetProfiles getProfiles;

  StreamSubscription<bool>? _premiumSubscription;
  bool _notificationScheduled = false;
  bool _disposed = false;

  HomeController({
    required this.repository,
    required this.getBooks,
    required this.getProfiles,
  });

  List<Book> books = [];
  List<ReaderProfile> profiles = [];
  ReaderProfile? activeProfile;
  bool loading = true;
  String? loadError;
  String loadPhase = '';
  bool actionLoading = false;
  bool isPremium = false;
  int coins = 0;
  int streakDays = 0;
  String accountUid = '';
  String accountName = '';
  String accountEmail = '';
  String accountPhotoUrl = '';
  String accountBio = '';
  List<String> accountFavoriteGenres = [];
  String accountMembership = 'free';
  int accountMaxProfiles = 4;
  int accountMaxDevices = 2;
  int accountCoinsDaily = 20;
  bool accountBasicAI = true;
  bool accountAdvancedAI = false;
  DateTime? accountCreatedAt;
  String accountSubscriptionStatus = 'active';
  String selectedProfileId = '';
  ReaderDashboard readerDashboard = const ReaderDashboard();

  static const int maxProfiles = 4;
  List<ReaderProfile> get readerProfiles {
    return profiles
        .where((profile) => accountUid.isEmpty || profile.id != accountUid)
        .toList(growable: false);
  }

  int get totalProfileTokens {
    return readerProfiles.fold<int>(
      0,
      (total, profile) => total + profile.tokens,
    );
  }

  int get bestReadingStreak {
    return readerProfiles.fold<int>(
      0,
      (best, profile) =>
          profile.dailyStreak > best ? profile.dailyStreak : best,
    );
  }

  List<String> get availableCategories {
    final categories = books.map((book) => book.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<Book> get recommendedBooks => catalogBooks;

  List<Book> get catalogBooks {
    final profile = activeProfile;
    if (profile == null) return books;

    final preferences = profile.favoriteCategories
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();

    bool matchesPreference(Book book) {
      if (preferences.isEmpty) return true;
      return preferences.contains(book.category.toLowerCase()) ||
          preferences.contains(book.audience.toLowerCase());
    }

    if (profile.role == 'child' || profile.childMode) {
      return _sortByPreferences(
        books
            .where((book) => book.audience.toLowerCase() == 'kids')
            .toList(growable: false),
        preferences,
      );
    }

    if (profile.role == 'teen') {
      final teenCatalog = books
          .where(
            (book) =>
                book.audience == 'kids' ||
                book.audience == 'General' ||
                book.audience == 'adult',
          )
          .where(matchesPreference)
          .toList(growable: false);
      return teenCatalog;
    }

    return _sortByPreferences(
      books
          .where((book) => book.audience.toLowerCase() == 'adult')
          .toList(growable: false),
      preferences,
    );
  }

  bool get canCreateProfile {
    return readerProfiles.length < accountMaxProfiles;
  }

  void _notifySafely() {
    if (_disposed) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (_notificationScheduled) return;
      _notificationScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _notificationScheduled = false;
        if (!_disposed) notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  Future<void> load() async {
    _listenPremiumState();
    loading = true;
    loadError = null;
    loadPhase = 'Preparando Mini Read...';
    _notifySafely();

    try {
      loadPhase = 'Cargando catálogo y perfiles...';
      _notifySafely();
      debugPrint(
        'HomeController.load: cargando catálogo, perfiles y cuenta...',
      );
      final booksFuture = getBooks().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          debugPrint('HomeController.load: catálogo sin respuesta.');
          return const [];
        },
      );
      final profilesFuture = getProfiles().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Firestore no respondió al cargar los perfiles.',
        ),
      );
      final userStateFuture = repository.getUserState().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Firestore no respondió al cargar la cuenta.',
        ),
      );
      final (loadedBooks, loadedProfiles, userState) = await (
        booksFuture,
        profilesFuture,
        userStateFuture,
      ).wait;

      loadPhase = 'Organizando tu biblioteca...';
      _notifySafely();
      books = loadedBooks;
      profiles = loadedProfiles;
      isPremium = userState.isPremium;
      accountUid = userState.uid;
      accountName = userState.name;
      accountEmail = userState.email;
      accountPhotoUrl = userState.photoUrl;
      accountBio = userState.bio;
      accountFavoriteGenres = userState.favoriteGenres;
      accountMembership = userState.membership;
      accountMaxProfiles = userState.maxProfiles;
      accountMaxDevices = userState.maxDevices;
      accountCoinsDaily = userState.coinsDaily;
      accountBasicAI = userState.basicAI;
      accountAdvancedAI = userState.advancedAI;
      accountCreatedAt = userState.createdAt;
      accountSubscriptionStatus = userState.subscriptionStatus;
      selectedProfileId = userState.selectedProfileId;
      if (activeProfile != null &&
          !readerProfiles.any((profile) => profile.id == activeProfile!.id)) {
        activeProfile = null;
      }
      if (activeProfile == null && selectedProfileId.isNotEmpty) {
        for (final profile in readerProfiles) {
          if (profile.id == selectedProfileId) {
            activeProfile = profile;
            break;
          }
        }
      }
      loadPhase = 'Preparando tu espacio de lectura...';
      _notifySafely();
      await _loadBooksForActiveProfile();
      await _refreshReaderDashboard();
      _syncProfileStats();
      debugPrint('HomeController.load: carga completada.');
    } catch (e) {
      debugPrint('Error en HomeController.load(): $e');
      loadError = e is TimeoutException
          ? 'No pudimos conectar con tus perfiles. Revisa tu conexión e inténtalo nuevamente.'
          : 'No pudimos cargar tu cuenta. Inténtalo nuevamente.';
    } finally {
      loading = false;
      loadPhase = '';
      _notifySafely();
    }
  }

  void clearUserState() {
    _premiumSubscription?.cancel();
    _premiumSubscription = null;
    profiles = [];
    activeProfile = null;
    isPremium = false;
    coins = 0;
    streakDays = 0;
    accountUid = '';
    accountName = '';
    accountEmail = '';
    accountPhotoUrl = '';
    accountBio = '';
    accountFavoriteGenres = [];
    accountMembership = 'free';
    accountMaxProfiles = 4;
    accountMaxDevices = 2;
    accountCoinsDaily = 20;
    accountBasicAI = true;
    accountAdvancedAI = false;
    accountCreatedAt = null;
    accountSubscriptionStatus = 'active';
    selectedProfileId = '';
    readerDashboard = const ReaderDashboard();
    loadError = null;
    loadPhase = '';
    loading = false;
    _notifySafely();
  }

  Future<void> selectProfile(ReaderProfile profile) async {
    actionLoading = true;
    _notifySafely();
    try {
      final checkedInProfile = await repository
          .checkInProfile(profile)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              debugPrint(
                'HomeController.selectProfile: check-in sin respuesta.',
              );
              return profile;
            },
          );
      _replaceProfile(checkedInProfile);
      activeProfile = checkedInProfile;
      selectedProfileId = checkedInProfile.id;
      await _loadBooksForActiveProfile();
      try {
        await repository
            .saveSelectedProfileId(checkedInProfile.id)
            .timeout(const Duration(seconds: 8));
      } catch (error) {
        debugPrint(
          'HomeController.selectProfile: no se pudo guardar selectedProfileId: $error',
        );
      }
      await _refreshReaderDashboard();
      _syncProfileStats();
    } finally {
      actionLoading = false;
      _notifySafely();
    }
  }

  Future<ReaderProfile> createProfile(OnboardingProfileDraft draft) async {
    if (!canCreateProfile) {
      throw Exception('Has alcanzado el limite de perfiles de tu plan actual.');
    }
    final childMode = draft.ageGroup == 'Ninos';
    final colors = childMode
        ? const [0xFFFF8FB3, 0xFF7ED7C1, 0xFFFFC857, 0xFF8EA7FF]
        : const [0xFF1B263B, 0xFFD4AF37, 0xFF637A8B, 0xFF76608A];
    final profile = ReaderProfile(
      id: 'profile-${DateTime.now().millisecondsSinceEpoch}',
      name: draft.name.trim().isEmpty ? 'Lector' : draft.name.trim(),
      role: childMode ? 'child' : 'adult',
      tokens: 0,
      dailyStreak: 0,
      ageGroup: childMode ? 'Ninos' : 'Adultos',
      readingMood: draft.readingMood,
      favoriteCategories: draft.favoriteCategories,
      childMode: childMode,
      accentColor: colors[readerProfiles.length % colors.length],
    );

    profiles = [...profiles, profile];
    await repository.saveProfile(profile);
    _notifySafely();
    return profile;
  }

  Future<void> updateReaderProfile(ReaderProfile profile) async {
    await repository.saveProfile(profile);
    _replaceProfile(profile);
    if (activeProfile?.id == profile.id) {
      activeProfile = profile;
      await _refreshReaderDashboard();
      _syncProfileStats();
    }
    _notifySafely();
  }

  Future<String> uploadReaderProfileAvatar({
    required String profileId,
    required List<int> imageBytes,
    String contentType = 'image/jpeg',
  }) {
    return repository.uploadProfileAvatar(
      profileId: profileId,
      imageBytes: imageBytes,
      contentType: contentType,
    );
  }

  Future<void> deleteReaderProfile(String profileId) async {
    await repository.deleteProfile(profileId);
    profiles = profiles.where((profile) => profile.id != profileId).toList();
    if (activeProfile?.id == profileId) activeProfile = null;
    if (selectedProfileId == profileId) {
      selectedProfileId = '';
      await repository.saveSelectedProfileId('');
    }
    await _refreshReaderDashboard();
    _syncProfileStats();
    _notifySafely();
  }

  Future<void> rewardAdWatched() async {
    if (isPremium) return;

    final profile = activeProfile;
    if (profile == null) return;

    actionLoading = true;
    _notifySafely();
    final updatedTokens = await repository.rewardAdTokens(
      profileId: profile.id,
    );
    final updated = profile.copyWith(tokens: updatedTokens);
    _replaceProfile(updated);
    activeProfile = updated;
    _syncProfileStats();
    actionLoading = false;
    _notifySafely();
  }

  Future<void> upgradeToPremium() async {
    actionLoading = true;
    _notifySafely();

    try {
      await repository.updatePremiumStatus(true);
      isPremium = true;
    } finally {
      actionLoading = false;
      _notifySafely();
    }
  }

  Future<void> updateUserProfile({
    required String displayName,
    required String bio,
    required List<String> favoriteGenres,
    List<int>? avatarBytes,
    String avatarContentType = 'image/jpeg',
  }) async {
    actionLoading = true;
    _notifySafely();

    try {
      String? nextPhotoUrl;
      if (avatarBytes != null && avatarBytes.isNotEmpty) {
        nextPhotoUrl = await repository.uploadUserAvatar(
          imageBytes: avatarBytes,
          contentType: avatarContentType,
        );
      }

      await repository.updateUserProfile(
        displayName: displayName,
        bio: bio,
        favoriteGenres: favoriteGenres,
        photoUrl: nextPhotoUrl,
      );

      accountName = displayName;
      accountBio = bio;
      accountFavoriteGenres = favoriteGenres;
      if (nextPhotoUrl != null && nextPhotoUrl.isNotEmpty) {
        accountPhotoUrl = nextPhotoUrl;
      }
    } finally {
      actionLoading = false;
      _notifySafely();
    }
  }

  Future<void> sharePremiumStreak() async {
    if (!isPremium) return;

    final profileName = activeProfile?.name ?? 'Mini Read';
    final text =
        'Tarjeta Mini Read: $profileName lleva $streakDays dias de racha lectora. Lectura Premium, IA ilimitada y constancia lista para compartir.';

    await Share.share(text, subject: 'Mi racha de lectura en Mini Read');
  }

  Future<void> activateProfileFor(String profileId) async {
    ReaderProfile? matchingProfile;
    for (final profile in profiles) {
      if (profile.id == profileId) {
        matchingProfile = profile;
        break;
      }
    }
    if (matchingProfile == null || activeProfile?.id == profileId) return;
    await selectProfile(matchingProfile);
  }

  int costFor(AiQuestionType type) {
    return type.tokenCost;
  }

  bool canAsk(AiQuestionType type) {
    return isPremium || coins >= costFor(type);
  }

  Future<AiAccessResult> validateAiAccess({
    required AiQuestionType type,
    required Book book,
    BookPage? page,
  }) async {
    final profile = activeProfile;
    if (profile == null) {
      return AiAccessResult(
        granted: false,
        premium: isPremium,
        currentTokens: coins,
        cost: costFor(type),
      );
    }

    final result = await repository.validateAndSpendAiTokens(
      profileId: profile.id,
      type: type,
      bookId: book.id,
      pageNumber: page?.pageNumber,
    );

    isPremium = result.premium || isPremium;
    if (!result.premium && result.granted) {
      final updated = profile.copyWith(tokens: result.currentTokens);
      _replaceProfile(updated);
      activeProfile = updated;
      _syncProfileStats();
    }
    _notifySafely();
    return result;
  }

  Future<void> saveReadingProgress(Book book, int pageIndex) async {
    final profile = activeProfile;
    if (profile == null) return;
    await repository.saveReadingProgress(
      profileId: profile.id,
      bookId: book.id,
      lastPageRead: pageIndex + 1,
    );
    await _refreshReaderDashboard();
    _notifySafely();
  }

  Future<void> saveAiMessage({
    required Book book,
    required AiQuestionType type,
    required String question,
    required String answer,
    BookPage? page,
  }) async {
    final profile = activeProfile;
    if (profile == null) return;
    await repository.saveAiMessage(
      profileId: profile.id,
      bookId: book.id,
      type: type,
      question: question,
      answer: answer,
      pageNumber: page?.pageNumber,
      pageContext: page?.text,
    );
  }

  String mockAiAnswer({
    required Book book,
    required AiQuestionType type,
    required String question,
    BookPage? page,
  }) {
    final scope = type == AiQuestionType.page && page != null
        ? 'esta pagina, "${page.title}"'
        : 'el libro completo';

    return 'Sobre $scope de "${book.title}": la idea central se relaciona con ${book.category.toLowerCase()}, decisiones de los personajes y el tono de la escena. En la version con backend, esta respuesta se generara usando solo el contenido autorizado de este libro.';
  }

  void _listenPremiumState() {
    _premiumSubscription?.cancel();
    _premiumSubscription = repository.watchPremiumStatus().listen((premium) {
      if (isPremium == premium) return;
      isPremium = premium;
      _syncProfileStats();
      _notifySafely();
    });
  }

  List<Book> _sortByPreferences(List<Book> source, Set<String> preferences) {
    if (preferences.isEmpty) return source;

    final preferred = <Book>[];
    final rest = <Book>[];
    for (final book in source) {
      final matches =
          preferences.contains(book.category.toLowerCase()) ||
          preferences.contains(book.audience.toLowerCase());
      if (matches) {
        preferred.add(book);
      } else {
        rest.add(book);
      }
    }

    return [...preferred, ...rest];
  }

  Future<void> _refreshReaderDashboard() async {
    final profileId = activeProfile?.id ?? '';
    try {
      readerDashboard = await repository
          .getReaderDashboard(books: books, profileId: profileId)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              debugPrint('HomeController.load: dashboard sin respuesta.');
              return const ReaderDashboard();
            },
          );
    } catch (_) {
      readerDashboard = const ReaderDashboard();
    }
  }

  Future<void> _loadBooksForActiveProfile() async {
    final profile = activeProfile;
    if (profile == null) return;
    final audience = profile.role == 'child' || profile.childMode
        ? 'kids'
        : 'adult';
    print('HomeController audience selected: $audience');
    books = await repository
        .getBooksByAudience(audience)
        .timeout(const Duration(seconds: 12), onTimeout: () => const []);
    for (final book in books) {
      if (book.title.toLowerCase().contains('colmillo blanco')) {
        print('HomeController Colmillo blanco PDF URL: ${book.pdfUrl}');
      }
    }
  }

  void _syncProfileStats() {
    final profile = activeProfile;
    coins = isPremium ? 0 : profile?.tokens ?? 0;
    streakDays = profile?.dailyStreak ?? 0;
  }

  void _replaceProfile(ReaderProfile updatedProfile) {
    profiles = [
      for (final profile in profiles)
        if (profile.id == updatedProfile.id) updatedProfile else profile,
    ];
  }

  @override
  void dispose() {
    _disposed = true;
    _premiumSubscription?.cancel();
    super.dispose();
  }
}
