import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AccountService {
  final fb.FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AccountService({required this.auth, required this.firestore});

  Future<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _requireUser();
    await _reauthenticate(user: user, password: currentPassword);
    // Mini Read keeps the authenticated email and the legacy user document in sync.
    // ignore: deprecated_member_use
    await user.updateEmail(newEmail.trim());
    await firestore.collection('users').doc(user.uid).set({
      'email': newEmail.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    await _reauthenticate(user: user, password: currentPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _requireUser();
    await _reauthenticate(user: user, password: currentPassword);
    await _deleteUserData(user.uid);
    await user.delete();
    await auth.signOut();
  }

  fb.User _requireUser() {
    final user = auth.currentUser;
    if (user == null || (user.email ?? '').isEmpty) {
      throw Exception('Debes iniciar sesión nuevamente.');
    }
    return user;
  }

  Future<void> _reauthenticate({
    required fb.User user,
    required String password,
  }) {
    final credential = fb.EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    return user.reauthenticateWithCredential(credential);
  }

  Future<void> _deleteUserData(String uid) async {
    final userDoc = firestore.collection('users').doc(uid);

    for (final path in const ['favorites', 'reading_progress', 'perfiles']) {
      final snapshot = await userDoc.collection(path).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    await userDoc.delete();
  }
}
