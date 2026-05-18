import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user_model.dart';
import 'firebase_auth_datasource.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDocument(credential.user);
      return UserModel.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('El email no es válido.');
        case 'user-disabled':
          throw Exception('El usuario está deshabilitado.');
        case 'user-not-found':
          throw Exception('Usuario no encontrado.');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta.');
        default:
          throw Exception(e.message ?? 'Error desconocido.');
      }
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDocument(credential.user);
      return UserModel.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('El email no es válido.');
        case 'email-already-in-use':
          throw Exception('El email ya está en uso.');
        case 'weak-password':
          throw Exception('La contraseña es muy débil.');
        default:
          throw Exception(e.message ?? 'Error desconocido.');
      }
    }
  }

  Future<void> _ensureUserDocument(fb.User? user) async {
    if (user == null) return;

    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      await ref.set({
        'email': user.email,
        if (!data.containsKey('isPremium')) 'isPremium': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? user.email?.split('@').first ?? 'Usuario',
      'role': 'user',
      'isPremium': false,
      'preferences': <String, Object?>{},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
