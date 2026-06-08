enum AiQuestionType { page, general }

extension AiQuestionTypeCost on AiQuestionType {
  int get tokenCost {
    return this == AiQuestionType.page ? 5 : 10;
  }

  String get firestoreValue {
    return this == AiQuestionType.page ? 'page' : 'general';
  }
}

class AiAccessResult {
  final bool granted;
  final bool premium;
  final int currentTokens;
  final int cost;

  const AiAccessResult({
    required this.granted,
    required this.premium,
    required this.currentTokens,
    required this.cost,
  });
}
