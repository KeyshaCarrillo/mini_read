import '../core/formatters.dart';

class IaChat {
  final String id;
  final String uid;
  final String profileId;
  final String bookId;
  final String question;
  final String answer;
  final DateTime? createdAt;

  const IaChat({
    required this.id,
    required this.uid,
    required this.profileId,
    required this.bookId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory IaChat.fromJson(Map<String, dynamic> json) {
    return IaChat(
      id: '${json['id'] ?? ''}',
      uid: '${json['uid'] ?? ''}',
      profileId: '${json['profileId'] ?? ''}',
      bookId: '${json['bookId'] ?? ''}',
      question: '${json['question'] ?? ''}',
      answer: '${json['answer'] ?? ''}',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
