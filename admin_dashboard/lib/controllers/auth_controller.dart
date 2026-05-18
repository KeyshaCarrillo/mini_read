import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';

enum AuthStatus { checking, signedOut, signedIn, forbidden }

class AuthController extends ChangeNotifier {
  final AdminApiService _api;
  final FirebaseAuth _auth;

  AuthController(this._api, {FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  AuthStatus status = AuthStatus.checking;
  String? errorMessage;
  Map<String, dynamic>? profile;

  User? get user => _auth.currentUser;
  String get displayName =>
      '${profile?['name'] ?? user?.displayName ?? user?.email ?? 'Admin'}';
  String get role => '${profile?['role'] ?? 'admin'}';

  Future<void> bootstrap() async {
    status = AuthStatus.checking;
    notifyListeners();
    if (_auth.currentUser == null) {
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }
    await _validateAdmin();
  }

  Future<void> signIn(String email, String password) async {
    status = AuthStatus.checking;
    errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _validateAdmin();
    } on FirebaseAuthException catch (error) {
      status = AuthStatus.signedOut;
      errorMessage = error.message ?? 'No se pudo iniciar sesion.';
      notifyListeners();
    } on AdminApiException catch (error) {
      status = error.statusCode == 403
          ? AuthStatus.forbidden
          : AuthStatus.signedOut;
      errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      status = AuthStatus.signedOut;
      errorMessage = 'No se pudo conectar con el panel admin.';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    profile = null;
    errorMessage = null;
    status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<void> _validateAdmin() async {
    try {
      profile = await _api.getMe();
      final currentRole = '${profile?['role'] ?? ''}';
      final isAdmin = currentRole == 'admin' || currentRole == 'owner';
      status = isAdmin ? AuthStatus.signedIn : AuthStatus.forbidden;
      errorMessage = isAdmin
          ? null
          : 'Tu cuenta existe, pero requiere role "admin" u "owner" en Firestore.';
      notifyListeners();
    } on AdminApiException catch (error) {
      status = error.statusCode == 403
          ? AuthStatus.forbidden
          : AuthStatus.signedOut;
      errorMessage = error.message;
      notifyListeners();
    }
  }
}
