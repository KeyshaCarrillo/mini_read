class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String audience;
  final String ageGroup;
  final String bookType;
  final List<String> tags;
  final String description;
  final String coverUrl;
  final String pdfUrl;
  final String coverPath;
  final String pdfPath;
  final bool active;
  final bool featured;
  final String sourceName;
  final String sourceUrl;
  final int accentColor;
  final int estimatedMinutes;
  final int pageCount;
  final String language;
  final double rating;
  final bool aiEnabled;
  final String summary;
  final List<String> keywords;
  final bool hasImmersiveImages;
  final List<BookPage> pages;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.audience,
    this.ageGroup = '',
    this.bookType = '',
    this.tags = const [],
    required this.description,
    this.coverUrl = '',
    this.pdfUrl = '',
    this.coverPath = '',
    this.pdfPath = '',
    this.active = true,
    this.featured = false,
    required this.sourceName,
    required this.sourceUrl,
    required this.accentColor,
    required this.estimatedMinutes,
    this.pageCount = 0,
    this.language = 'Español',
    this.rating = 0,
    this.aiEnabled = false,
    this.summary = '',
    this.keywords = const [],
    required this.hasImmersiveImages,
    required this.pages,
  });
}

class BookPage {
  final int pageNumber;
  final String title;
  final String body;
  final String? illustration;
  final String? imageUrl;

  const BookPage({
    required this.pageNumber,
    required this.title,
    required this.body,
    this.illustration,
    this.imageUrl,
  });

  String get text => body;
}
