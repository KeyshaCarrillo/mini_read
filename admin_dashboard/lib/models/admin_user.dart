import '../core/formatters.dart';

class AdminUser {
  final String id;
  final String uid;
  final String email;
  final String name;
  final String username;
  final String nickname;
  final String role;
  final bool isPremium;
  final bool banned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUser({
    required this.id,
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.nickname,
    required this.role,
    required this.isPremium,
    required this.banned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: '${json['id'] ?? json['docId'] ?? json['uid'] ?? ''}',
      uid: '${json['uid'] ?? ''}',
      email: '${json['email'] ?? 'sin-correo'}',
      name: '${json['name'] ?? json['displayName'] ?? 'Usuario'}',
      username: '${json['username'] ?? json['userName'] ?? ''}',
      nickname:
          '${json['nickname'] ?? json['nickName'] ?? json['alias'] ?? ''}',
      role: '${json['role'] ?? 'user'}',
      isPremium: json['isPremium'] == true,
      banned: json['banned'] == true || json['disabled'] == true,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  AdminUser copyWith({String? role, bool? isPremium, bool? banned}) {
    return AdminUser(
      id: id,
      uid: uid,
      email: email,
      name: name,
      username: username,
      nickname: nickname,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      banned: banned ?? this.banned,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
