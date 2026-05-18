import 'package:flutter/foundation.dart';

import '../../domain/entities/ai_access.dart';
import '../../domain/entities/book.dart';
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

class LibraryController extends ChangeNotifier {
  final LibraryRepository repository;
  final GetBooks getBooks;
  final GetProfiles getProfiles;

  LibraryController({
    required this.repository,
    required this.getBooks,
    required this.getProfiles,
  }) {
    load();
  }

  List<Book> books = [];
  List<ReaderProfile> profiles = [];
  ReaderProfile? activeProfile;
  bool loading = true;
  bool actionLoading = false;
  bool isPremium = false;
  int coins = 0;
  int streakDays = 0;

  static const int maxProfiles = 4;

  List<String> get availableCategories {
    final categories = books.map((book) => book.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      // Intentamos cargar todo en paralelo de forma segura
      final loadedBooks = await getBooks();
      final loadedProfiles = await getProfiles();
      final userState = await repository.getUserState();

      books = loadedBooks;
      profiles = loadedProfiles;
      isPremium = userState.isPremium;
      activeProfile ??= profiles.isNotEmpty ? profiles.first : null;
      _syncProfileStats();
    } catch (e) {
      // Si el backend de Vercel o Firebase falla, evitamos que la app colapse
      debugPrint('Error en LibraryController.load(): $e');
      books =
          []; // Mantenemos la lista limpia para mostrar el estado vacío/conector
    } finally {
      // Esto se ejecuta SÍ O SÍ, asegurando que la interfaz se entere del cambio
      loading = false;
      notifyListeners();
    }
  }

  void clearUserState() {
    profiles = [];
    activeProfile = null;
    isPremium = false;
    coins = 0;
    streakDays = 0;
    loading = false;
    notifyListeners();
  }

  List<Book> get childBooks {
    return books.where((book) => book.audience == 'Ninos').toList();
  }

  List<Book> get generalBooks {
    return books.where((book) => book.audience != 'Ninos').toList();
  }

  List<Book> get recommendedBooks {
    final profile = activeProfile;
    if (profile == null || profile.favoriteCategories.isEmpty) {
      return books;
    }

    final preferred = books.where((book) {
      return profile.favoriteCategories.contains(book.category) ||
          profile.favoriteCategories.contains(book.audience);
    }).toList();

    if (profile.childMode) {
      final childPreferred = preferred
          .where((book) => book.audience == 'Ninos')
          .toList();
      return childPreferred.isEmpty ? childBooks : childPreferred;
    }

    return preferred.isEmpty ? generalBooks : preferred;
  }

  bool get canCreateProfile {
    return profiles.length < maxProfiles;
  }

  Future<void> selectProfile(ReaderProfile profile) async {
    activeProfile = profile;
    _syncProfileStats();
    notifyListeners();

    actionLoading = true;
    notifyListeners();
    final checkedInProfile = await repository.checkInProfile(profile);
    _replaceProfile(checkedInProfile);
    activeProfile = checkedInProfile;
    _syncProfileStats();
    actionLoading = false;
    notifyListeners();
  }

  Future<ReaderProfile> createProfile(OnboardingProfileDraft draft) async {
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
      ageGroup: draft.ageGroup,
      readingMood: draft.readingMood,
      favoriteCategories: draft.favoriteCategories,
      childMode: childMode,
      accentColor: colors[profiles.length % colors.length],
    );

    if (profiles.length >= maxProfiles) {
      profiles = [...profiles.take(maxProfiles - 1), profile];
    } else {
      profiles = [...profiles, profile];
    }
    await repository.saveProfile(profile);
    activeProfile = profile;
    _syncProfileStats();
    notifyListeners();
    return profile;
  }

  Future<void> rewardAdWatched() async {
    final profile = activeProfile;
    if (profile == null) return;

    actionLoading = true;
    notifyListeners();
    final updatedTokens = await repository.rewardAdTokens(
      profileId: profile.id,
    );
    final updated = profile.copyWith(tokens: updatedTokens);
    _replaceProfile(updated);
    activeProfile = updated;
    _syncProfileStats();
    actionLoading = false;
    notifyListeners();
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
    notifyListeners();
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

  void _syncProfileStats() {
    final profile = activeProfile;
    coins = profile?.tokens ?? 0;
    streakDays = profile?.dailyStreak ?? 0;
  }

  void _replaceProfile(ReaderProfile updatedProfile) {
    profiles = [
      for (final profile in profiles)
        if (profile.id == updatedProfile.id) updatedProfile else profile,
    ];
  }
}
