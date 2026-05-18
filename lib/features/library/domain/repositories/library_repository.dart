import '../entities/ai_access.dart';
import '../entities/book.dart';
import '../entities/reader_profile.dart';
import '../entities/user_library_state.dart';

abstract class LibraryRepository {
  Future<List<Book>> getBooks();
  Future<List<ReaderProfile>> getProfiles();
  Future<UserLibraryState> getUserState();
  Stream<bool> watchPremiumStatus();
  Future<void> updatePremiumStatus(bool isPremium);
  Future<void> saveProfile(ReaderProfile profile);
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
