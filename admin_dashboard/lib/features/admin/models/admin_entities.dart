import 'package:flutter/foundation.dart';

@immutable
class AdminBook {
  const AdminBook({
    required this.id,
    required this.title,
    required this.category,
    required this.pages,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String category;
  final int pages;
  final Map<String, dynamic> raw;

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    final id = _stringValue(json, ['id', '_id', 'bookId', 'docId']);
    return AdminBook(
      id: id.isEmpty ? _stringValue(json, ['title', 'name']) : id,
      title: _stringValue(json, ['title', 'name', 'bookTitle'], fallback: 'Untitled book'),
      category: _stringValue(json, ['category', 'genre', 'type'], fallback: 'General'),
      pages: _intValue(json, ['pages', 'pageCount', 'totalPages']),
      raw: json,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'id': id,
        'title': title,
        'category': category,
        'pages': pages,
      };
}

@immutable
class AdminUser {
  const AdminUser({
    required this.docId,
    required this.name,
    required this.email,
    required this.plan,
    required this.status,
    required this.tokens,
    this.raw = const {},
  });

  final String docId;
  final String name;
  final String email;
  final String plan;
  final String status;
  final int tokens;
  final Map<String, dynamic> raw;

  bool get isPremium => plan.toLowerCase().contains('premium') || plan.toLowerCase().contains('plus');
  bool get isBanned => status.toLowerCase().contains('ban') || status.toLowerCase().contains('blocked');

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final firstName = _stringValue(json, ['firstName', 'name', 'displayName', 'fullName']);
    final lastName = _stringValue(json, ['lastName']);
    return AdminUser(
      docId: _stringValue(json, ['docId', 'id', '_id', 'uid', 'userId']),
      name: [firstName, lastName].where((value) => value.trim().isNotEmpty).join(' ').trim().isEmpty
          ? 'Usuario sin nombre'
          : [firstName, lastName].where((value) => value.trim().isNotEmpty).join(' '),
      email: _stringValue(json, ['email', 'mail'], fallback: 'sin-email@mini-read.app'),
      plan: _stringValue(json, ['plan', 'membership', 'tier'], fallback: _boolValue(json, ['premium', 'isPremium']) ? 'Premium' : 'Free'),
      status: _stringValue(json, ['status', 'state'], fallback: _boolValue(json, ['banned', 'isBanned']) ? 'Banned' : 'Active'),
      tokens: _intValue(json, ['tokens', 'coins', 'balance', 'tokenBalance']),
      raw: json,
    );
  }

  AdminUser copyWith({String? plan, String? status}) => AdminUser(
        docId: docId,
        name: name,
        email: email,
        plan: plan ?? this.plan,
        status: status ?? this.status,
        tokens: tokens,
        raw: raw,
      );
}

@immutable
class TokenTransaction {
  const TokenTransaction({
    required this.id,
    required this.user,
    required this.type,
    required this.rewardType,
    required this.amount,
    required this.createdAt,
    this.raw = const {},
  });

  final String id;
  final String user;
  final String type;
  final String rewardType;
  final int amount;
  final DateTime createdAt;
  final Map<String, dynamic> raw;

  bool get isAdReward {
    final value = '$type $rewardType'.toLowerCase();
    return value.contains('ad') || value.contains('anuncio') || value.contains('reward');
  }

  bool get isAiQuery {
    final value = '$type $rewardType'.toLowerCase();
    return value.contains('ai') || value.contains('ia') || value.contains('consulta') || value.contains('query');
  }

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: _stringValue(json, ['id', '_id', 'transactionId', 'docId']),
      user: _stringValue(json, ['user', 'userName', 'email', 'userId', 'uid'], fallback: 'Usuario desconocido'),
      type: _stringValue(json, ['type', 'transactionType', 'source'], fallback: 'Movimiento'),
      rewardType: _stringValue(json, ['rewardType', 'reason', 'description'], fallback: 'Sin detalle'),
      amount: _intValue(json, ['amount', 'tokens', 'coins', 'value']),
      createdAt: _dateValue(json, ['createdAt', 'date', 'timestamp', 'updatedAt']),
      raw: json,
    );
  }
}

class MonthlyTokenUsage {
  const MonthlyTokenUsage({required this.monthLabel, required this.adsTokens, required this.aiTokens});

  final String monthLabel;
  final double adsTokens;
  final double aiTokens;
}

String _stringValue(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) return value.toString();
  }
  return fallback;
}

int _intValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
  }
  return 0;
}

bool _boolValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
  }
  return false;
}

DateTime _dateValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
