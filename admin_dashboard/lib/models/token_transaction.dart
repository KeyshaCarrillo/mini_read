import '../core/formatters.dart';

class TokenTransaction {
  final String id;
  final String uid;
  final String profileId;
  final String bookId;
  final String type;
  final int amount;
  final DateTime? createdAt;

  const TokenTransaction({
    required this.id,
    required this.uid,
    required this.profileId,
    required this.bookId,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: '${json['id'] ?? ''}',
      uid: '${json['uid'] ?? ''}',
      profileId: '${json['profileId'] ?? ''}',
      bookId: '${json['bookId'] ?? ''}',
      type: '${json['type'] ?? 'movimiento'}',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(json['createdAt']),
    );
  }

  bool get isReward => amount >= 0;

  String get label {
    if (type.contains('ai')) return 'Consumo IA';
    if (type.contains('rewarded')) return 'Recompensa anuncio';
    if (type.contains('daily')) return 'Racha diaria';
    if (type.contains('premium')) return 'Suscripcion premium';
    return type;
  }
}
