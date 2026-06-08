import 'dart:typed_data';

import '../../domain/entities/ai_access.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reader_dashboard.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/entities/user_library_state.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/firebase_library_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final BookRepository bookRepository;
  final FirebaseLibraryDataSource? firebaseDataSource;

  const LibraryRepositoryImpl({
    required this.bookRepository,
    this.firebaseDataSource,
  });

  @override
  Future<List<Book>> getBooks() async {
    try {
      return await bookRepository.getBooks();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Book>> getBooksByAudience(String audience) async {
    try {
      return await bookRepository.getBooksByAudience(audience);
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

    return firebase.getProfiles();
  }

  @override
  Future<UserLibraryState> getUserState() async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) {
      return const UserLibraryState(isPremium: false);
    }

    return firebase.getUserState();
  }

  @override
  Future<ReaderDashboard> getReaderDashboard({
    required List<Book> books,
    required String profileId,
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) {
      return const ReaderDashboard();
    }

    try {
      return await firebase.getReaderDashboard(
        books: books,
        profileId: profileId,
      );
    } catch (_) {
      return const ReaderDashboard();
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
  Future<void> updateUserProfile({
    required String displayName,
    required String bio,
    required List<String> favoriteGenres,
    String? photoUrl,
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.updateUserProfile(
      displayName: displayName,
      bio: bio,
      favoriteGenres: favoriteGenres,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<String> uploadUserAvatar({
    required List<int> imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return '';
    return firebase.uploadUserAvatar(
      imageBytes: Uint8List.fromList(imageBytes),
      contentType: contentType,
    );
  }

  @override
  Future<String> uploadProfileAvatar({
    required String profileId,
    required List<int> imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return '';
    return firebase.uploadProfileAvatar(
      profileId: profileId,
      imageBytes: Uint8List.fromList(imageBytes),
      contentType: contentType,
    );
  }

  @override
  Future<void> saveProfile(ReaderProfile profile) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.saveProfile(profile);
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.deleteProfile(profileId);
  }

  @override
  Future<void> saveSelectedProfileId(String profileId) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return;
    await firebase.saveSelectedProfileId(profileId);
  }

  @override
  Future<ReaderProfile> checkInProfile(ReaderProfile profile) async {
    final firebase = firebaseDataSource;
    if (firebase == null || firebase.currentUid == null) return profile;
    try {
      return await firebase.checkInProfile(profile);
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
