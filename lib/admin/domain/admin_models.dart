class AdminBook {
  final String id;
  final String title;
  final String author;
  final String category;
  final String audience;
  final int pagesCount;
  final DateTime? updatedAt;

  const AdminBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.audience,
    required this.pagesCount,
    this.updatedAt,
  });

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    final pages = json['pages'];
    return AdminBook(
      id: (json['id'] ?? json['bookId'] ?? '').toString(),
      title: (json['title'] ?? 'Sin titulo').toString(),
      author: (json['author'] ?? 'Autor desconocido').toString(),
      category: (json['category'] ?? 'General').toString(),
      audience: (json['audience'] ?? 'General').toString(),
      pagesCount: pages is List
          ? pages.length
          : (json['pagesCount'] as num?)?.toInt() ?? 0,
      updatedAt: _date(json['updatedAt']),
    );
  }
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final bool isPremium;
  final bool isAdmin;
  final bool isBanned;
  final int tokens;
  final DateTime? updatedAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isPremium,
    required this.isAdmin,
    required this.isBanned,
    required this.tokens,
    this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? json['type'] ?? '').toString().toLowerCase();
    final subscription = (json['subscription'] ?? json['plan'] ?? '')
        .toString()
        .toLowerCase();
    return AdminUser(
      id: (json['id'] ?? json['uid'] ?? json['docId'] ?? '').toString(),
      name: (json['name'] ?? json['displayName'] ?? json['username'] ?? 'Usuario')
          .toString(),
      email: (json['email'] ?? 'Sin correo').toString(),
      isPremium:
          json['isPremium'] == true ||
          json['premium'] == true ||
          subscription == 'premium',
      isAdmin: json['isAdmin'] == true || role == 'admin',
      isBanned: json['isBanned'] == true || json['banned'] == true,
      tokens: (json['tokens'] as num?)?.toInt() ?? 0,
      updatedAt: _date(json['updatedAt']),
    );
  }
}

class TokenTransaction {
  final String id;
  final String uid;
  final String profileId;
  final String type;
  final int amount;
  final String reward;
  final DateTime? createdAt;

  const TokenTransaction({
    required this.id,
    required this.uid,
    required this.profileId,
    required this.type,
    required this.amount,
    required this.reward,
    this.createdAt,
  });

  bool get isAiQuery {
    final normalized = type.toLowerCase();
    return normalized.contains('ai') ||
        normalized.contains('ia') ||
        normalized.contains('chat') ||
        normalized.contains('question');
  }

  bool get isRewardAd {
    final normalized = type.toLowerCase();
    return normalized.contains('ad') ||
        normalized.contains('video') ||
        normalized.contains('reward');
  }

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: (json['id'] ?? json['transactionId'] ?? '').toString(),
      uid: (json['uid'] ?? json['userId'] ?? '').toString(),
      profileId: (json['profileId'] ?? '').toString(),
      type: (json['type'] ?? json['source'] ?? 'movimiento').toString(),
      amount: (json['amount'] as num?)?.toInt() ??
          (json['tokens'] as num?)?.toInt() ??
          0,
      reward: (json['reward'] ?? json['description'] ?? json['reason'] ?? '')
          .toString(),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AiChatLog {
  final String id;
  final String uid;
  final String question;
  final String answer;
  final DateTime? createdAt;

  const AiChatLog({
    required this.id,
    required this.uid,
    required this.question,
    required this.answer,
    this.createdAt,
  });

  factory AiChatLog.fromJson(Map<String, dynamic> json) {
    return AiChatLog(
      id: (json['id'] ?? '').toString(),
      uid: (json['uid'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      createdAt: _date(json['createdAt']),
    );
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
