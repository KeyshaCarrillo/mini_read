import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.category,
    required super.audience,
    required super.description,
    required super.sourceName,
    required super.sourceUrl,
    required super.accentColor,
    required super.estimatedMinutes,
    required super.hasImmersiveImages,
    required super.pages,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final pages = (json['pages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BookPageModel.fromJson)
        .toList(growable: false);

    return BookModel(
      id: _stringValue(json['id'] ?? json['bookId'], fallback: ''),
      title: _stringValue(json['title'], fallback: 'Sin titulo'),
      author: _stringValue(json['author'], fallback: 'Autor desconocido'),
      category: _stringValue(json['category'], fallback: 'General'),
      audience: _normalizeAudience(json['audience']),
      description: _stringValue(json['description']),
      sourceName: _stringValue(json['sourceName'], fallback: 'API de libros'),
      sourceUrl: _stringValue(json['sourceUrl']),
      accentColor: _parseColor(json['accentColor']),
      estimatedMinutes:
          (json['estimatedMinutes'] as num?)?.toInt() ??
          _estimateMinutes(pages),
      hasImmersiveImages:
          json['hasImmersiveImages'] == true ||
          pages.any(
            (page) => page.imageUrl != null && page.imageUrl!.isNotEmpty,
          ),
      pages: pages,
    );
  }

  static String _stringValue(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String _normalizeAudience(Object? value) {
    final audience = _stringValue(value, fallback: 'General');
    final lower = audience.toLowerCase();
    if (lower == 'ninos' || lower == 'niños' || lower == 'children') {
      return 'Ninos';
    }
    if (lower == 'adultos' || lower == 'adult' || lower == 'adults') {
      return 'Adultos';
    }
    return 'General';
  }

  static int _estimateMinutes(List<BookPageModel> pages) {
    final words = pages.fold<int>(
      0,
      (total, page) => total + page.body.split(RegExp(r'\s+')).length,
    );
    return (words / 180).ceil().clamp(1, 120);
  }

  static int _parseColor(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value
          .trim()
          .replaceFirst('#', '')
          .replaceFirst(RegExp('^0x', caseSensitive: false), '');
      final withAlpha = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
      return int.tryParse(withAlpha, radix: 16) ?? 0xFF1B263B;
    }
    return 0xFF1B263B;
  }
}

class BookPageModel extends BookPage {
  const BookPageModel({
    required super.pageNumber,
    required super.title,
    required super.body,
    super.illustration,
    super.imageUrl,
  });

  factory BookPageModel.fromJson(Map<String, dynamic> json) {
    return BookPageModel(
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      title: BookModel._stringValue(json['title'], fallback: 'Pagina'),
      body: BookModel._stringValue(json['text'] ?? json['body']),
      illustration: BookModel._stringValue(json['illustration']).isEmpty
          ? null
          : BookModel._stringValue(json['illustration']),
      imageUrl: BookModel._stringValue(json['imageUrl']).isEmpty
          ? null
          : BookModel._stringValue(json['imageUrl']),
    );
  }
}
