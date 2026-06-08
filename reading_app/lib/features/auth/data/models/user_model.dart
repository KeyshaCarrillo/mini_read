import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
  });

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
    );
  }
}
