/// Entidad de usuario en el dominio
class User {
  final String id;
  final String email;
  final String name;
  final String photoUrl;

  User({
    required this.id,
    required this.email,
    this.name = '',
    this.photoUrl = '',
  });
}
