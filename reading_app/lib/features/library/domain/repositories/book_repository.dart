import '../entities/book.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<List<Book>> getFeaturedBooks();
  Future<List<Book>> getBooksByAudience(String audience);
  Future<List<Book>> getBooksByCategory(String category);
  Future<List<Book>> searchBooks(String query);
  Future<List<Book>> getInfantilBooks();
  Future<void> ensureInfantilBooks();
}
