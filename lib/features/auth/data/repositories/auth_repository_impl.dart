import 'package:mini_read/features/auth/domain/entities/user.dart';
import 'package:mini_read/features/auth/domain/repositories/auth_repository.dart';
import 'package:mini_read/features/auth/data/datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      return await dataSource.login(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      return await dataSource.register(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }
}
