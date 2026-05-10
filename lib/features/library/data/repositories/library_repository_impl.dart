import '../../domain/entities/book.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/local_library_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LocalLibraryDataSource dataSource;

  const LibraryRepositoryImpl(this.dataSource);

  @override
  Future<List<Book>> getBooks() {
    return dataSource.getBooks();
  }

  @override
  Future<List<ReaderProfile>> getProfiles() {
    return dataSource.getProfiles();
  }
}
