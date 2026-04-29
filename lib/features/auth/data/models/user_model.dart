import 'package:mini_read/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email});

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(id: firebaseUser.uid, email: firebaseUser.email);
  }
}
