import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  const StorageService(this._storage);

  Reference ref(String path) => _storage.ref(path);

  Future<String> uploadImageBytes({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    SettableMetadata? metadata,
  }) async {
    final uploadMetadata =
        metadata ?? SettableMetadata(contentType: contentType);
    final snapshot = await ref(path).putData(bytes, uploadMetadata);
    return snapshot.ref.getDownloadURL();
  }

  Future<void> deleteByPath(String path) {
    return ref(path).delete();
  }

  Future<String> getDownloadUrl(String path) {
    return ref(path).getDownloadURL();
  }
}
