import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SearchBooks {
  final BookRepository repository;

  const SearchBooks(this.repository);

  Future<List<Book>> call(String query) {
    return repository.searchBooks(query);
  }
}
