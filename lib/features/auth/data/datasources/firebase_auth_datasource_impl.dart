import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import 'firebase_auth_datasource.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  FirebaseAuthDataSourceImpl(this._firebaseAuth);

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
}
