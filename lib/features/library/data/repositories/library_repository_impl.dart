import '../../domain/entities/ai_access.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/entities/user_library_state.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/book_api_datasource.dart';
import '../datasources/firebase_library_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final BookApiDataSource bookApiDataSource;
  final FirebaseLibraryDataSource? firebaseDataSource;

  const LibraryRepositoryImpl({
    required this.bookApiDataSource,
    this.firebaseDataSource,
  });

  @override
  Future<List<Book>> getBooks() async {
    try {
      return await bookApiDataSource.getBooks();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ReaderProfile>> getProfiles() async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) {
      return const [];
    }

    try {
      return await firebase.getProfiles();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<UserLibraryState> getUserState() async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) {
      return const UserLibraryState(isPremium: false);
    }

    try {
      return await firebase.getUserState();
    } catch (_) {
      return const UserLibraryState(isPremium: false);
    }
  }

  @override
  Stream<bool> watchPremiumStatus() {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) {
      return Stream<bool>.value(false);
    }

    return firebase.watchPremiumStatus();
  }

  @override
  Future<void> updatePremiumStatus(bool isPremium) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.updatePremiumStatus(isPremium);
  }

  @override
  Future<void> saveProfile(ReaderProfile profile) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.saveProfile(profile);
  }

  @override
  Future<ReaderProfile> checkInProfile(ReaderProfile profile) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return profile;
    try {
      return firebase.checkInProfile(profile);
    } catch (_) {
      return profile;
    }
  }

  @override
  Future<AiAccessResult> validateAndSpendAiTokens({
    required String profileId,
    required AiQuestionType type,
    required String bookId,
    int? pageNumber,
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) {
      return AiAccessResult(
        granted: false,
        premium: false,
        currentTokens: 0,
        cost: type.tokenCost,
      );
    }

    return firebase.validateAndSpendAiTokens(
      profileId: profileId,
      type: type,
      bookId: bookId,
      pageNumber: pageNumber,
    );
  }

  @override
  Future<int> rewardAdTokens({
    required String profileId,
    int amount = 30,
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return amount;
    return firebase.rewardAdTokens(profileId: profileId, amount: amount);
  }

  @override
  Future<void> saveReadingProgress({
    required String profileId,
    required String bookId,
    required int lastPageRead,
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.saveReadingProgress(
      profileId: profileId,
      bookId: bookId,
      lastPageRead: lastPageRead,
    );
  }

  @override
  Future<void> saveAiMessage({
    required String profileId,
    required String bookId,
    required AiQuestionType type,
    required String question,
    required String answer,
    int? pageNumber,
    String? pageContext,
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.saveAiMessage(
      profileId: profileId,
      bookId: bookId,
      type: type,
      question: question,
      answer: answer,
      pageNumber: pageNumber,
      pageContext: pageContext,
    );
  }
}
