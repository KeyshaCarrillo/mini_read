import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/entities/user.dart';

class AuthController {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthController({required this.loginUser, required this.registerUser});

  Future<User?> login(String email, String password) async {
    try {
      return await loginUser(email: email, password: password);
    } catch (e) {
      throw e is Exception ? e : Exception(e.toString());
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      return await registerUser(email: email, password: password);
    } catch (e) {
      throw e is Exception ? e : Exception(e.toString());
    }
  }
}
