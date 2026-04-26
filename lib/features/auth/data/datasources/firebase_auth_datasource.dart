import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password});
}
