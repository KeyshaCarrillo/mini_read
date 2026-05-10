import 'package:flutter/foundation.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/get_profiles.dart';

enum AiQuestionType { page, general }

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

  void selectProfile(ReaderProfile profile) {
    activeProfile = profile;
    notifyListeners();
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
