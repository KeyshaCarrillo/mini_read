import '../entities/book.dart';
import '../entities/reader_profile.dart';

abstract class LibraryRepository {
  Future<List<Book>> getBooks();
  Future<List<ReaderProfile>> getProfiles();
}
