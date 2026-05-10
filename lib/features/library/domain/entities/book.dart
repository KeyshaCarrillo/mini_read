class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String audience;
  final String description;
  final String sourceName;
  final String sourceUrl;
  final int accentColor;
  final int estimatedMinutes;
  final bool hasImmersiveImages;
  final List<BookPage> pages;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.audience,
    required this.description,
    required this.sourceName,
    required this.sourceUrl,
    required this.accentColor,
    required this.estimatedMinutes,
    required this.hasImmersiveImages,
    required this.pages,
  });
}

class BookPage {
  final int pageNumber;
  final String title;
  final String body;
  final String? illustration;

  const BookPage({
    required this.pageNumber,
    required this.title,
    required this.body,
    this.illustration,
  });
}
