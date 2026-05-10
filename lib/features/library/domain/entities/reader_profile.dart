class ReaderProfile {
  final String id;
  final String name;
  final String ageGroup;
  final String readingMood;
  final List<String> favoriteCategories;
  final bool childMode;
  final int accentColor;

  const ReaderProfile({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.readingMood,
    required this.favoriteCategories,
    required this.childMode,
    required this.accentColor,
  });
}
