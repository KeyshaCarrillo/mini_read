import 'package:flutter/foundation.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';

class BookController extends ChangeNotifier {
  final BookRepository repository;

  BookController({required this.repository});

  bool loading = false;
  String? error;
  List<Book> books = const [];
  String _currentAudience = '';

  String get currentAudience => _currentAudience;

  Future<void> loadAll() => _run(repository.getBooks);

  Future<void> loadByAudience(String audience) async {
    _currentAudience = audience.trim().toLowerCase();
    await _run(() => repository.getBooksByAudience(audience));
  }

  Future<void> reloadCurrent() {
    if (_currentAudience.isNotEmpty) {
      return loadByAudience(_currentAudience);
    }
    return loadAll();
  }

  void _logBooks(List<Book> loadedBooks) {
    for (final book in loadedBooks) {
      debugPrint('Book ID: ${book.id}');
      debugPrint('Title: ${book.title}');
      debugPrint('PDF URL: ${book.pdfUrl}');
      debugPrint('Audience: ${book.audience}');
      print('PDF URL: ${book.pdfUrl}');
    }
  }

  Future<void> _run(Future<List<Book>> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      books = await action();
      _logBooks(books);
    } catch (exception) {
      error = exception.toString();
      books = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadBooks() async {
    await loadAll();
  }

  Future<void> loadFeatured() async {
    await _run(repository.getFeaturedBooks);
  }

  Future<void> search(String query) async {
    await _run(() => repository.searchBooks(query));
  }

  Future<void> loadCategory(String category) async {
    await _run(() => repository.getBooksByCategory(category));
  }

  Future<void> loadAudience(String audience) async {
    await loadByAudience(audience);
  }
}

class BookProvider extends BookController {
  BookProvider({required super.repository});
}
