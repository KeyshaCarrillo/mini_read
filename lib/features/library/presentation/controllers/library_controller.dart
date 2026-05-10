import 'package:flutter/foundation.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/get_profiles.dart';

enum AiQuestionType { page, general }

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
  final GetBooks getBooks;
  final GetProfiles getProfiles;

  LibraryController({required this.getBooks, required this.getProfiles});

  List<Book> books = [];
  List<ReaderProfile> profiles = [];
  ReaderProfile? activeProfile;
  bool loading = true;
  bool isPremium = false;
  int coins = 80;
  int streakDays = 3;

  static const int maxProfiles = 4;

  List<String> get availableCategories {
    final categories = books.map((book) => book.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final loadedBooks = await getBooks();
    final loadedProfiles = await getProfiles();

    books = loadedBooks;
    profiles = loadedProfiles;
    activeProfile ??= profiles.isNotEmpty ? profiles.first : null;
    loading = false;
    notifyListeners();
  }

  List<Book> get childBooks {
    return books.where((book) => book.audience == 'Niños').toList();
  }

  List<Book> get generalBooks {
    return books.where((book) => book.audience != 'Niños').toList();
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
          .where((book) => book.audience == 'Niños')
          .toList();
      return childPreferred.isEmpty ? childBooks : childPreferred;
    }

    return preferred.isEmpty ? generalBooks : preferred;
  }

  bool get canCreateProfile {
    return profiles.length < maxProfiles;
  }

  void selectProfile(ReaderProfile profile) {
    activeProfile = profile;
    notifyListeners();
  }

  ReaderProfile createDemoProfile(OnboardingProfileDraft draft) {
    final childMode = draft.ageGroup == 'Niños';
    final colors = childMode
        ? const [0xFFFF8FB3, 0xFF7ED7C1, 0xFFFFC857, 0xFF8EA7FF]
        : const [0xFF5B7C62, 0xFF6FA8C8, 0xFF76608A, 0xFFE36B5D];
    final profile = ReaderProfile(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      name: draft.name.trim().isEmpty ? 'Lector' : draft.name.trim(),
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
    activeProfile = profile;
    notifyListeners();
    return profile;
  }

  void togglePremiumPreview() {
    isPremium = !isPremium;
    notifyListeners();
  }

  void claimDailyReward() {
    coins += 20;
    streakDays += 1;
    notifyListeners();
  }

  void rewardAdWatched() {
    coins += 30;
    notifyListeners();
  }

  int costFor(AiQuestionType type) {
    return type == AiQuestionType.page ? 5 : 10;
  }

  bool canAsk(AiQuestionType type) {
    return isPremium || coins >= costFor(type);
  }

  bool spendForQuestion(AiQuestionType type) {
    if (isPremium) return true;
    final cost = costFor(type);
    if (coins < cost) return false;
    coins -= cost;
    notifyListeners();
    return true;
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
}
