import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  const FirestoreService(this._firestore);

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> document({
    required String collectionPath,
    required String documentId,
  }) {
    return _firestore.collection(collectionPath).doc(documentId);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return document(
      collectionPath: collectionPath,
      documentId: documentId,
    ).get();
  }

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) {
    return document(
      collectionPath: collectionPath,
      documentId: documentId,
    ).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return document(
      collectionPath: collectionPath,
      documentId: documentId,
    ).update(data);
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return document(
      collectionPath: collectionPath,
      documentId: documentId,
    ).delete();
  }

  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final ref = await collection(collectionPath).add(data);
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
    queryBuilder,
  }) {
    final query = collection(collectionPath);
    final built = queryBuilder == null ? query : queryBuilder(query);
    return built.snapshots();
  }
}
