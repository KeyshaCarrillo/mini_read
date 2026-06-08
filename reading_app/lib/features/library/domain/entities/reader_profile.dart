class ReaderProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;
  final int tokens;
  final int dailyStreak;
  final DateTime? lastLoginDate;
  final String ageGroup;
  final String readingMood;
  final List<String> favoriteCategories;
  final bool childMode;
  final bool pinEnabled;
  final String pinCode;
  final int accentColor;

  const ReaderProfile({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.role = 'adult',
    this.tokens = 0,
    this.dailyStreak = 0,
    this.lastLoginDate,
    required this.ageGroup,
    required this.readingMood,
    required this.favoriteCategories,
    bool? childMode,
    this.pinEnabled = false,
    this.pinCode = '',
    required this.accentColor,
  }) : childMode = childMode ?? role == 'child' || ageGroup == 'Ninos';

  ReaderProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? role,
    int? tokens,
    int? dailyStreak,
    DateTime? lastLoginDate,
    String? ageGroup,
    String? readingMood,
    List<String>? favoriteCategories,
    bool? childMode,
    bool? pinEnabled,
    String? pinCode,
    int? accentColor,
  }) {
    return ReaderProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      tokens: tokens ?? this.tokens,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      ageGroup: ageGroup ?? this.ageGroup,
      readingMood: readingMood ?? this.readingMood,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      childMode: childMode ?? this.childMode,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinCode: pinCode ?? this.pinCode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}
