import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  final fb.FirebaseAuth _auth;

  const AuthService(this._auth);

  fb.User? get currentUser => _auth.currentUser;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  Future<fb.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<fb.UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
