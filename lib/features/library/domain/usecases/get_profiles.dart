import '../entities/reader_profile.dart';
import '../repositories/library_repository.dart';

class GetProfiles {
  final LibraryRepository repository;

  const GetProfiles(this.repository);

  Future<List<ReaderProfile>> call() {
    return repository.getProfiles();
  }
}
