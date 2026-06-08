import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/reading_progress.dart';

class UserBookService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const UserBookService({required this.firestore, required this.auth});

  String? get _uid => auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favoritesRef {
    final uid = _uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('favorites');
  }

  CollectionReference<Map<String, dynamic>>? get _progressRef {
    final uid = _uid;
    if (uid == null) return null;
    return firestore
        .collection('users')
        .doc(uid)
        .collection('reading_progress');
  }

  Future<Set<String>> getFavoriteIds() async {
    final ref = _favoritesRef;
    if (ref == null) return <String>{};
    final snapshot = await ref.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<List<String>> getFavoriteBookIds() async {
    final ref = _favoritesRef;
    if (ref == null) return const [];
    final snapshot = await ref.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.id).toList(growable: false);
  }

  Future<bool> isFavorite(String bookId) async {
    final ref = _favoritesRef;
    if (ref == null) return false;
    return (await ref.doc(bookId).get()).exists;
  }

  Future<void> addFavorite(Book book) async {
    final ref = _favoritesRef;
    if (ref == null) return;
    await ref.doc(book.id).set({
      'bookId': book.id,
      'title': book.title,
      'coverUrl': book.coverUrl,
      'pdfUrl': book.pdfUrl,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavorite(String bookId) async {
    final ref = _favoritesRef;
    if (ref == null) return;
    await ref.doc(bookId).delete();
  }

  Future<void> saveProgress({
    required String bookId,
    required int currentPage,
    required int totalPages,
  }) async {
    final ref = _progressRef;
    if (ref == null || bookId.isEmpty) return;
    final safeTotal = totalPages <= 0 ? currentPage : totalPages;
    final progress = safeTotal <= 0 ? 0.0 : currentPage / safeTotal;
    await ref.doc(bookId).set({
      'bookId': bookId,
      'currentPage': currentPage,
      'totalPages': safeTotal,
      'progressPercentage': progress.clamp(0, 1),
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<ReadingProgress?> getProgress(String bookId) async {
    final ref = _progressRef;
    if (ref == null) return null;
    final doc = await ref.doc(bookId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    final timestamp = data['lastReadAt'];
    return ReadingProgress(
      bookId: data['bookId']?.toString() ?? doc.id,
      currentPage: (data['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
      progressPercentage: (data['progressPercentage'] as num?)?.toDouble() ?? 0,
      lastReadAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  Future<List<ReadingProgress>> getContinueReading({int limit = 10}) async {
    final ref = _progressRef;
    if (ref == null) return const [];
    final snapshot = await ref
        .orderBy('lastReadAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          final timestamp = data['lastReadAt'];
          return ReadingProgress(
            bookId: data['bookId']?.toString() ?? doc.id,
            currentPage: (data['currentPage'] as num?)?.toInt() ?? 1,
            totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
            progressPercentage:
                (data['progressPercentage'] as num?)?.toDouble() ?? 0,
            lastReadAt: timestamp is Timestamp ? timestamp.toDate() : null,
          );
        })
        .toList(growable: false);
  }
}
