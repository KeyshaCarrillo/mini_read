import '../entities/ai_access.dart';
import '../entities/book.dart';
import '../entities/reader_dashboard.dart';
import '../entities/reader_profile.dart';
import '../entities/user_library_state.dart';

abstract class LibraryRepository {
  Future<List<Book>> getBooks();
  Future<List<Book>> getBooksByAudience(String audience);
  Future<List<ReaderProfile>> getProfiles();
  Future<UserLibraryState> getUserState();
  Future<ReaderDashboard> getReaderDashboard({
    required List<Book> books,
    required String profileId,
  });
  Stream<bool> watchPremiumStatus();
  Future<void> updatePremiumStatus(bool isPremium);
  Future<void> updateUserProfile({
    required String displayName,
    required String bio,
    required List<String> favoriteGenres,
    String? photoUrl,
  });
  Future<String> uploadUserAvatar({
    required List<int> imageBytes,
    String contentType,
  });
  Future<String> uploadProfileAvatar({
    required String profileId,
    required List<int> imageBytes,
    String contentType,
  });
  Future<void> saveProfile(ReaderProfile profile);
  Future<void> deleteProfile(String profileId);
  Future<void> saveSelectedProfileId(String profileId);
  Future<ReaderProfile> checkInProfile(ReaderProfile profile);
  Future<AiAccessResult> validateAndSpendAiTokens({
    required String profileId,
    required AiQuestionType type,
    required String bookId,
    int? pageNumber,
  });
  Future<int> rewardAdTokens({required String profileId, int amount = 30});
  Future<void> saveReadingProgress({
    required String profileId,
    required String bookId,
    required int lastPageRead,
  });
  Future<void> saveAiMessage({
    required String profileId,
    required String bookId,
    required AiQuestionType type,
    required String question,
    required String answer,
    int? pageNumber,
    String? pageContext,
  });
}
