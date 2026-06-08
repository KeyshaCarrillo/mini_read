import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/user_model.dart';
import 'firebase_auth_datasource.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  FirebaseAuthDataSourceImpl(this._authService, this._firestoreService);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signIn(
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
          throw Exception('Cuenta no encontrada.');
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
      final credential = await _authService.register(
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

    final ref = _firestoreService.document(
      collectionPath: 'users',
      documentId: user.uid,
    );
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      await ref.set({
        'email': user.email,
        if ((user.displayName ?? '').trim().isNotEmpty)
          'name': user.displayName,
        if ((user.photoURL ?? '').trim().isNotEmpty) 'photoUrl': user.photoURL,
        if (!data.containsKey('isPremium')) 'isPremium': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? user.email?.split('@').first ?? user.uid,
      'photoUrl': user.photoURL ?? '',
      'role': 'user',
      'plan': 'free',
      'maxProfiles': 4,
      'maxDevices': 2,
      'coinsDaily': 20,
      'basicAI': true,
      'advancedAI': false,
      'isPremium': false,
      'preferences': <String, Object?>{},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
