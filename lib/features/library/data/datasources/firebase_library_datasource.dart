import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/ai_access.dart';
import '../../domain/entities/reader_profile.dart';
import '../../domain/entities/user_library_state.dart';

class FirebaseLibraryDataSource {
  final FirebaseFirestore firestore;
  final fb.FirebaseAuth auth;

  const FirebaseLibraryDataSource({
    required this.firestore,
    required this.auth,
  });

  String? get currentUid => auth.currentUser?.uid;

  Future<UserLibraryState> getUserState() async {
    final uid = currentUid;
    if (uid == null) return const UserLibraryState(isPremium: false);

    final snapshot = await firestore.collection('users').doc(uid).get();
    final data = snapshot.data();
    return UserLibraryState(isPremium: data?['isPremium'] == true);
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

  Future<ReaderProfile> checkInProfile(ReaderProfile profile) async {
    final uid = currentUid;
    if (uid == null) return profile;

    final ref = firestore
        .collection('users')
        .doc(uid)
        .collection('perfiles')
        .doc(profile.id);

    return firestore.runTransaction((transaction) async {
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
      final tokenReward = wasYesterday ? 20 : 20;
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

      final transactionRef = firestore.collection('token_transactions').doc();
      transaction.set(transactionRef, {
        'uid': uid,
        'profileId': profile.id,
        'amount': tokenReward,
        'type': 'daily_streak',
        'createdAt': FieldValue.serverTimestamp(),
      });

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
    final role = (data['role'] as String?) ?? 'adult';
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
          (data['favoriteCategories'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
      accentColor: (data['accentColor'] as num?)?.toInt() ?? 0xFF1B263B,
    );
  }

  Map<String, Object?> _profileToFirestore(ReaderProfile profile) {
    return {
      'name': profile.name,
      'avatarUrl': profile.avatarUrl,
      'role': profile.role,
      'tokens': profile.tokens,
      'dailyStreak': profile.dailyStreak,
      'lastLoginDate': profile.lastLoginDate == null
          ? null
          : Timestamp.fromDate(profile.lastLoginDate!),
      'ageGroup': profile.ageGroup,
      'readingMood': profile.readingMood,
      'favoriteCategories': profile.favoriteCategories,
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
}
