import 'package:flutter/material.dart';

class KpiMetric {
  const KpiMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaLabel,
    required this.icon,
    required this.color,
    required this.trend,
  });

  final String label;
  final String value;
  final double delta;
  final String deltaLabel;
  final IconData icon;
  final Color color;
  final List<double> trend;
}

class ChartPoint {
  const ChartPoint(this.label, this.value, this.secondaryValue);
  final String label;
  final double value;
  final double secondaryValue;
}

class ActivityRecord {
  const ActivityRecord({
    required this.user,
    required this.email,
    required this.action,
    required this.status,
    required this.plan,
    required this.time,
    required this.initials,
  });

  final String user;
  final String email;
  final String action;
  final String status;
  final String plan;
  final String time;
  final String initials;
}

class SegmentMetric {
  const SegmentMetric({required this.name, required this.value, required this.color});
  final String name;
  final double value;
  final Color color;
}

class AdminBook {
  const AdminBook({
    required this.id,
    required this.title,
    required this.category,
    required this.pages,
    this.author = '',
    this.coverUrl = '',
  });

  final String id;
  final String title;
  final String category;
  final int pages;
  final String author;
  final String coverUrl;

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    return AdminBook(
      id: _string(json, ['id', 'bookId']),
      title: _string(json, ['title', 'titulo', 'name']),
      category: _string(json, ['category', 'categoria', 'genre'], fallback: 'Sin categoría'),
      pages: _int(json, ['pages', 'paginas', 'pageCount']),
      author: _string(json, ['author', 'autor']),
      coverUrl: _string(json, ['coverUrl', 'cover', 'imageUrl']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'pages': pages,
        if (author.isNotEmpty) 'author': author,
        if (coverUrl.isNotEmpty) 'coverUrl': coverUrl,
      };
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.plan,
    required this.isPremium,
    required this.isBanned,
    this.tokens = 0,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String plan;
  final bool isPremium;
  final bool isBanned;
  final int tokens;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final isPremium = _bool(json, ['isPremium', 'premium']) || _string(json, ['plan', 'subscription', 'subscriptionStatus']).toLowerCase().contains('premium');
    return AdminUser(
      id: _string(json, ['id', 'uid', 'docId']),
      name: _string(json, ['name', 'displayName', 'nombre'], fallback: 'Usuario sin nombre'),
      email: _string(json, ['email', 'correo'], fallback: 'sin-email@mini.read'),
      role: _string(json, ['role', 'rol'], fallback: 'reader'),
      plan: isPremium ? 'Premium' : _string(json, ['plan', 'subscription'], fallback: 'Free'),
      isPremium: isPremium,
      isBanned: _bool(json, ['isBanned', 'banned', 'disabled']),
      tokens: _int(json, ['tokens', 'tokenBalance', 'coins']),
    );
  }

  String get initials {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return 'US';
    final parts = cleanName.split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part.substring(0, 1).toUpperCase()).join();
  }
}

class TokenTransaction {
  const TokenTransaction({
    required this.id,
    required this.user,
    required this.type,
    required this.rewardType,
    required this.amount,
    required this.createdAt,
    this.description = '',
  });

  final String id;
  final String user;
  final String type;
  final String rewardType;
  final int amount;
  final DateTime? createdAt;
  final String description;

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: _string(json, ['id', 'transactionId']),
      user: _string(json, ['user', 'uid', 'userId', 'email'], fallback: 'Usuario desconocido'),
      type: _string(json, ['type', 'source', 'action'], fallback: 'Movimiento'),
      rewardType: _string(json, ['rewardType', 'reason', 'category'], fallback: 'Tokens'),
      amount: _int(json, ['amount', 'tokens', 'delta', 'value']),
      createdAt: _date(json, ['createdAt', 'timestamp', 'date']),
      description: _string(json, ['description', 'detail', 'message']),
    );
  }

  bool get isAi => '${type.toLowerCase()} ${rewardType.toLowerCase()}'.contains('ia') || '${type.toLowerCase()} ${rewardType.toLowerCase()}'.contains('ai');
  bool get isAd => '${type.toLowerCase()} ${rewardType.toLowerCase()}'.contains('ad') || '${type.toLowerCase()} ${rewardType.toLowerCase()}'.contains('anuncio');
}

String _string(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) return value.toString();
  }
  return fallback;
}

int _int(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
  }
  return 0;
}

bool _bool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
  }
  return false;
}

DateTime? _date(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Map && value['_seconds'] is int) {
      return DateTime.fromMillisecondsSinceEpoch((value['_seconds'] as int) * 1000);
    }
  }
  return null;
}
