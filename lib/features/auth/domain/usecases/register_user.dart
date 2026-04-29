import 'package:mini_read/features/auth/domain/entities/user.dart';
import 'package:mini_read/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<User> call({required String email, required String password}) async {
    return await repository.register(email: email, password: password);
  }
}
