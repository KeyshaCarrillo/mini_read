import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetFeaturedBooks {
  final BookRepository repository;

  const GetFeaturedBooks(this.repository);

  Future<List<Book>> call() {
    return repository.getFeaturedBooks();
  }
}
