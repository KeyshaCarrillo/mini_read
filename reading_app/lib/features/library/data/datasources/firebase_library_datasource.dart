import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/ai_access.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/plan_capabilities.dart';
import '../../domain/entities/reader_dashboard.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/entities/user_library_state.dart';

class FirebaseLibraryDataSource {
  final FirebaseFirestore firestore;
  final fb.FirebaseAuth auth;
  final FirestoreService? firestoreService;
  final CloudinaryService? cloudinaryService;

  const FirebaseLibraryDataSource({
    required this.firestore,
    required this.auth,
    this.firestoreService,
    this.cloudinaryService,
  });

  String? get currentUid => auth.currentUser?.uid;

  Future<UserLibraryState> getUserState() async {
    final uid = currentUid;
    if (uid == null) return const UserLibraryState(isPremium: false);

    final authUser = auth.currentUser;
    final snapshot = await firestore.collection('users').doc(uid).get();
    final data = snapshot.data();
    final email = _firstNonEmpty([data?['email'], authUser?.email]);
    final name = _firstNonEmpty([
      data?['name'],
      data?['displayName'],
      authUser?.displayName,
      email.contains('@') ? email.split('@').first : null,
      uid,
    ]);
    final photoUrl = _firstNonEmpty([
      data?['photoUrl'],
      data?['photoURL'],
      data?['avatarUrl'],
      authUser?.photoURL,
    ]);
    final favoriteGenres =
        (data?['favoriteGenres'] as List<dynamic>?)
            ?.map((value) => value.toString())
            .where((value) => value.trim().isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
    final membership = _firstNonEmpty([
      data?['membership'],
      data?['plan'],
      data?['accountType'],
      data?['isPlus'] == true ? 'plus' : null,
      data?['isPremium'] == true ? 'premium' : 'free',
    ]).toLowerCase();
    final capabilities = PlanCapabilities.from(membership);
    final storedMaxProfiles = (data?['maxProfiles'] as num?)?.toInt() ?? 0;
    final storedMaxDevices = (data?['maxDevices'] as num?)?.toInt() ?? 0;

    return UserLibraryState(
      isPremium: data?['isPremium'] == true,
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      bio: (data?['bio'] as String?)?.trim() ?? '',
      favoriteGenres: favoriteGenres,
      membership: membership,
      maxProfiles: storedMaxProfiles < capabilities.maxProfiles
          ? capabilities.maxProfiles
          : storedMaxProfiles,
      maxDevices: storedMaxDevices < capabilities.maxDevices
          ? capabilities.maxDevices
          : storedMaxDevices,
      coinsDaily: capabilities.coinsDaily,
      basicAI: capabilities.basicAI,
      advancedAI: capabilities.advancedAI,
      createdAt: data?['createdAt'] is Timestamp
          ? (data!['createdAt'] as Timestamp).toDate()
          : authUser?.metadata.creationTime,
      subscriptionStatus: data?['subscriptionStatus']?.toString() ?? 'active',
      selectedProfileId: data?['selectedProfileId']?.toString() ?? '',
    );
  }

  Stream<bool> watchPremiumStatus() {
    final uid = currentUid;
    if (uid == null) return Stream<bool>.value(false);

    return firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['isPremium'] == true;
    });
  }

  Future<ReaderDashboard> getReaderDashboard({
    required List<Book> books,
    required String profileId,
  }) async {
    final uid = currentUid;
    if (uid == null || profileId.isEmpty) return const ReaderDashboard();

    final booksById = {for (final book in books) book.id: book};
    final snapshot = await firestore
        .collection('history_reading')
        .where('uid', isEqualTo: uid)
        .get();

    final entries = snapshot.docs
        .map((doc) => _readingEntryFromData(doc.data(), booksById))
        .whereType<_ReadingEntry>()
        .where((entry) => entry.profileId == profileId)
        .toList(growable: false);

    if (entries.isEmpty) return const ReaderDashboard();

    final sorted = [...entries]
      ..sort((a, b) {
        final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final inProgress = entries.where((entry) => entry.progress < 1).toList();
    final completed = entries.where((entry) => entry.progress >= 1).toList();
    final totalMinutes = entries.fold<int>(0, (total, entry) {
      final minutes = (entry.book.estimatedMinutes * entry.progress).round();
      return total + minutes.clamp(0, entry.book.estimatedMinutes);
    });
    final continueEntry = inProgress.isNotEmpty ? inProgress.first : null;

    return ReaderDashboard(
      booksRead: completed.length,
      booksInProgress: inProgress.length,
      favorites: 0,
      totalReadingMinutes: totalMinutes,
      continueReading: continueEntry == null
          ? null
          : ContinueReadingItem(
              book: continueEntry.book,
              profileId: continueEntry.profileId,
              lastPageRead: continueEntry.lastPageRead,
              progress: continueEntry.progress,
              updatedAt: continueEntry.updatedAt,
            ),
      recentActivity: sorted
          .take(5)
          .map(
            (entry) => RecentReadingActivity(
              book: entry.book,
              profileId: entry.profileId,
              lastPageRead: entry.lastPageRead,
              progress: entry.progress,
              updatedAt: entry.updatedAt,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    final uid = currentUid;
    if (uid == null) return;

    await firestore.collection('users').doc(uid).set({
      'isPremium': isPremium,
      'premiumUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile({
    required String displayName,
    required String bio,
    required List<String> favoriteGenres,
    String? photoUrl,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Debes iniciar sesion para editar tu perfil.');
    }

    await firestore.collection('users').doc(uid).set({
      'displayName': displayName,
      'name': displayName,
      'bio': bio,
      'favoriteGenres': favoriteGenres,
      'photoUrl': ?photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> uploadUserAvatar({
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Debes iniciar sesion para subir tu foto.');
    }

    final cloudinary = cloudinaryService;
    if (cloudinary == null) {
      throw Exception('CloudinaryService no esta configurado.');
    }

    if (kDebugMode) {
      debugPrint('Subiendo avatar usuario...');
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return cloudinary.uploadImageBytes(
      bytes: imageBytes,
      folder: 'mini_read/avatars/users/$uid',
      publicId: 'user_${uid}_$timestamp',
      contentType: contentType,
    );
  }

  Future<List<ReaderProfile>> getProfiles() async {
    final uid = currentUid;
    if (uid == null) return const [];

    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('perfiles')
        .get();

    return snapshot.docs.map((doc) => _profileFromDoc(doc)).toList();
  }

  Future<void> saveProfile(ReaderProfile profile) async {
    final uid = currentUid;
    if (uid == null) return;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('perfiles')
        .doc(profile.id)
        .set(_profileToFirestore(profile), SetOptions(merge: true));
  }

  Future<void> deleteProfile(String profileId) async {
    final uid = currentUid;
    if (uid == null) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('perfiles')
        .doc(profileId)
        .delete();
  }

  Future<void> saveSelectedProfileId(String profileId) async {
    final uid = currentUid;
    if (uid == null) return;
    await firestore.collection('users').doc(uid).set({
      'selectedProfileId': profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<ReaderProfile> checkInProfile(ReaderProfile profile) async {
    final uid = currentUid;
    if (uid == null) return profile;

    final userRef = firestore.collection('users').doc(uid);
    final ref = userRef.collection('perfiles').doc(profile.id);

    return firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final isPremium = userSnapshot.data()?['isPremium'] == true;
      final plan = PlanCapabilities.from(
        userSnapshot.data()?['plan']?.toString(),
      );
      final snapshot = await transaction.get(ref);
      final current = snapshot.exists
          ? _profileFromSnapshot(snapshot)
          : profile;
      final today = _dateOnly(DateTime.now());
      final lastLogin = current.lastLoginDate == null
          ? null
          : _dateOnly(current.lastLoginDate!);

      if (lastLogin != null && _sameDay(lastLogin, today)) {
        return current;
      }

      final wasYesterday =
          lastLogin != null &&
          _sameDay(lastLogin, today.subtract(const Duration(days: 1)));
      final nextStreak = wasYesterday ? current.dailyStreak + 1 : 1;
      final tokenReward = isPremium ? 0 : plan.coinsDaily;
      final updated = current.copyWith(
        dailyStreak: nextStreak,
        tokens: current.tokens + tokenReward,
        lastLoginDate: today,
      );

      transaction.set(ref, {
        'dailyStreak': updated.dailyStreak,
        'tokens': updated.tokens,
        'lastLoginDate': Timestamp.fromDate(today),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return updated;
    });
  }

  Future<AiAccessResult> validateAndSpendAiTokens({
    required String profileId,
    required AiQuestionType type,
    required String bookId,
    int? pageNumber,
  }) async {
    final uid = currentUid;
    final cost = type.tokenCost;
    if (uid == null) {
      return AiAccessResult(
        granted: false,
        premium: false,
        currentTokens: 0,
        cost: cost,
      );
    }

    final userRef = firestore.collection('users').doc(uid);
    final profileRef = userRef.collection('perfiles').doc(profileId);

    return firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final isPremium = userSnapshot.data()?['isPremium'] == true;
      final profileSnapshot = await transaction.get(profileRef);
      final profileData = profileSnapshot.data();
      final currentTokens = (profileData?['tokens'] as num?)?.toInt() ?? 0;

      if (isPremium) {
        return AiAccessResult(
          granted: true,
          premium: true,
          currentTokens: currentTokens,
          cost: 0,
        );
      }

      if (currentTokens < cost) {
        return AiAccessResult(
          granted: false,
          premium: false,
          currentTokens: currentTokens,
          cost: cost,
        );
      }

      final nextTokens = currentTokens - cost;
      transaction.update(profileRef, {
        'tokens': nextTokens,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(firestore.collection('token_transactions').doc(), {
        'uid': uid,
        'profileId': profileId,
        'bookId': bookId,
        'pageNumber': pageNumber,
        'amount': -cost,
        'type': 'ai_${type.firestoreValue}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AiAccessResult(
        granted: true,
        premium: false,
        currentTokens: nextTokens,
        cost: cost,
      );
    });
  }

  Future<int> rewardAdTokens({
    required String profileId,
    int amount = 30,
  }) async {
    final uid = currentUid;
    if (uid == null) return amount;

    final profileRef = firestore
        .collection('users')
        .doc(uid)
        .collection('perfiles')
        .doc(profileId);

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(profileRef);
      final currentTokens = (snapshot.data()?['tokens'] as num?)?.toInt() ?? 0;
      final nextTokens = currentTokens + amount;

      transaction.set(profileRef, {
        'tokens': nextTokens,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(firestore.collection('token_transactions').doc(), {
        'uid': uid,
        'profileId': profileId,
        'amount': amount,
        'type': 'rewarded_video',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return nextTokens;
    });
  }

  Future<void> saveReadingProgress({
    required String profileId,
    required String bookId,
    required int lastPageRead,
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    await firestore
        .collection('history_reading')
        .doc('$profileId-$bookId')
        .set({
          'uid': uid,
          'profileId': profileId,
          'bookId': bookId,
          'lastPageRead': lastPageRead,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> saveAiMessage({
    required String profileId,
    required String bookId,
    required AiQuestionType type,
    required String question,
    required String answer,
    int? pageNumber,
    String? pageContext,
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    await firestore.collection('ia_chats').add({
      'uid': uid,
      'profileId': profileId,
      'bookId': bookId,
      'pageNumber': pageNumber,
      'type': type.firestoreValue,
      'question': question,
      'answer': answer,
      'pageContext': pageContext,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // CRUD example for custom user notes in Firestore.
  Future<String> createUserNote({
    required String profileId,
    required String title,
    required String content,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Debes iniciar sesion para crear notas.');
    }

    final service = firestoreService;
    if (service == null) {
      throw Exception('FirestoreService no esta configurado.');
    }

    final collectionPath = 'users/$uid/perfiles/$profileId/notes';
    return service.addDocument(
      collectionPath: collectionPath,
      data: {
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> updateUserNote({
    required String profileId,
    required String noteId,
    required String title,
    required String content,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Debes iniciar sesion para editar notas.');
    }

    final service = firestoreService;
    if (service == null) {
      throw Exception('FirestoreService no esta configurado.');
    }

    await service.updateDocument(
      collectionPath: 'users/$uid/perfiles/$profileId/notes',
      documentId: noteId,
      data: {
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> deleteUserNote({
    required String profileId,
    required String noteId,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Debes iniciar sesion para eliminar notas.');
    }

    final service = firestoreService;
    if (service == null) {
      throw Exception('FirestoreService no esta configurado.');
    }

    await service.deleteDocument(
      collectionPath: 'users/$uid/perfiles/$profileId/notes',
      documentId: noteId,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserNotes({
    required String profileId,
  }) {
    final uid = currentUid;
    if (uid == null) {
      return Stream<QuerySnapshot<Map<String, dynamic>>>.error(
        Exception('Debes iniciar sesion para ver notas.'),
      );
    }

    final service = firestoreService;
    if (service == null) {
      return Stream<QuerySnapshot<Map<String, dynamic>>>.error(
        Exception('FirestoreService no esta configurado.'),
      );
    }

    return service.streamCollection(
      collectionPath: 'users/$uid/perfiles/$profileId/notes',
      queryBuilder: (query) => query.orderBy('updatedAt', descending: true),
    );
  }

  Future<String> uploadProfileAvatar({
    required String profileId,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Debes iniciar sesion para subir imagenes.');
    }

    final cloudinary = cloudinaryService;
    final service = firestoreService;
    if (cloudinary == null || service == null) {
      throw Exception('CloudinaryService o FirestoreService no configurados.');
    }

    if (kDebugMode) {
      debugPrint('Subiendo avatar perfil lector...');
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final downloadUrl = await cloudinary.uploadImageBytes(
      bytes: imageBytes,
      folder: 'mini_read/avatars/profiles/$profileId',
      publicId: 'profile_${profileId}_$timestamp',
      contentType: contentType,
    );

    await service.setDocument(
      collectionPath: 'users/$uid/perfiles',
      documentId: profileId,
      data: {
        'avatarUrl': downloadUrl,
        'avatarUpdatedAt': FieldValue.serverTimestamp(),
      },
      merge: true,
    );

    return downloadUrl;
  }

  ReaderProfile _profileFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return _profileFromData(doc.id, doc.data());
  }

  ReaderProfile _profileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return _profileFromData(snapshot.id, snapshot.data() ?? const {});
  }

  ReaderProfile _profileFromData(String id, Map<String, dynamic> data) {
    final isKids = data['isKids'] == true;
    final role = isKids ? 'child' : (data['role'] as String?) ?? 'adult';
    final lastLoginDate = data['lastLoginDate'];

    return ReaderProfile(
      id: id,
      name: (data['name'] as String?) ?? 'Lector',
      avatarUrl: (data['avatarUrl'] as String?) ?? '',
      role: role,
      tokens: (data['tokens'] as num?)?.toInt() ?? 0,
      dailyStreak: (data['dailyStreak'] as num?)?.toInt() ?? 0,
      lastLoginDate: lastLoginDate is Timestamp ? lastLoginDate.toDate() : null,
      ageGroup:
          (data['ageGroup'] as String?) ??
          (role == 'child' ? 'Ninos' : 'Adultos'),
      readingMood:
          (data['readingMood'] as String?) ?? 'Quiero descubrir buenos libros',
      favoriteCategories:
          (data['genres'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          (data['favoriteGenres'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          (data['preferences'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          (data['favoriteCategories'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
      accentColor: (data['accentColor'] as num?)?.toInt() ?? 0xFF1B263B,
      childMode: isKids || role == 'child',
      pinEnabled: !isKids && data['pinEnabled'] == true,
      pinCode: !isKids ? data['pinCode']?.toString() ?? '' : '',
    );
  }

  Map<String, Object?> _profileToFirestore(ReaderProfile profile) {
    return {
      'name': profile.name,
      'uid': currentUid,
      'avatarUrl': profile.avatarUrl,
      'role': profile.role,
      'isKids': profile.childMode,
      'pinEnabled': profile.childMode ? false : profile.pinEnabled,
      'pinCode': profile.childMode ? '' : profile.pinCode,
      'tokens': profile.tokens,
      'dailyStreak': profile.dailyStreak,
      'lastLoginDate': profile.lastLoginDate == null
          ? null
          : Timestamp.fromDate(profile.lastLoginDate!),
      'ageGroup': profile.ageGroup,
      'readingMood': profile.readingMood,
      'favoriteCategories': profile.favoriteCategories,
      'favoriteGenres': profile.favoriteCategories,
      'genres': profile.favoriteCategories,
      'preferences': profile.favoriteCategories,
      'accentColor': profile.accentColor,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  _ReadingEntry? _readingEntryFromData(
    Map<String, dynamic> data,
    Map<String, Book> booksById,
  ) {
    final bookId = data['bookId']?.toString();
    final profileId = data['profileId']?.toString() ?? '';
    if (bookId == null || bookId.isEmpty || profileId.isEmpty) return null;

    final book = booksById[bookId];
    if (book == null) return null;

    final lastPageRead = (data['lastPageRead'] as num?)?.toInt() ?? 0;
    final totalPages = book.pages.isNotEmpty
        ? book.pages.length
        : book.pdfUrl.trim().isNotEmpty
        ? 1
        : 1;
    final progress = (lastPageRead / totalPages).clamp(0.0, 1.0);
    final updatedAt = data['updatedAt'];

    return _ReadingEntry(
      book: book,
      profileId: profileId,
      lastPageRead: lastPageRead,
      progress: progress,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }
}

class _ReadingEntry {
  final Book book;
  final String profileId;
  final int lastPageRead;
  final double progress;
  final DateTime? updatedAt;

  const _ReadingEntry({
    required this.book,
    required this.profileId,
    required this.lastPageRead,
    required this.progress,
    this.updatedAt,
  });
}
