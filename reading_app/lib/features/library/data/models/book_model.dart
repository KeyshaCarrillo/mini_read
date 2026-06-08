import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.category,
    required super.audience,
    super.ageGroup,
    super.bookType,
    super.tags,
    required super.description,
    super.coverUrl,
    super.pdfUrl,
    super.coverPath,
    super.pdfPath,
    super.active,
    super.featured,
    required super.sourceName,
    required super.sourceUrl,
    required super.accentColor,
    required super.estimatedMinutes,
    super.pageCount,
    super.language,
    super.rating,
    super.aiEnabled,
    super.summary,
    super.keywords,
    required super.hasImmersiveImages,
    required super.pages,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final rawPages = json['pages'];
    final pages = (rawPages is List ? rawPages : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(BookPageModel.fromJson)
        .toList(growable: false);
    final keywords = _stringList(json['keywords']);

    final mappedPdfUrl = _stringValue(json['pdfUrl']);
    print(
      'BookModel.fromJson id=${_stringValue(json['id'] ?? json['bookId'], fallback: '')} pdfUrl=$mappedPdfUrl',
    );

    return BookModel(
      id: _stringValue(json['id'] ?? json['bookId'], fallback: ''),
      title: _stringValue(json['title'], fallback: 'Sin titulo'),
      author: _stringValue(json['author'], fallback: 'Autor desconocido'),
      category: _stringValue(json['category'], fallback: 'General'),
      audience: _normalizeAudience(json['audience']),
      ageGroup: _stringValue(json['ageGroup'] ?? json['ageRange']),
      bookType: _stringValue(json['bookType'] ?? json['type']),
      tags: _stringList(json['tags'] ?? json['keywords']),
      description: _stringValue(json['description']),
      coverUrl: _stringValue(json['coverUrl']),
      pdfUrl: mappedPdfUrl,
      coverPath: _stringValue(json['coverPath']),
      pdfPath: _stringValue(json['pdfPath']),
      active: json['active'] != false,
      featured: json['featured'] == true,
      sourceName: _stringValue(json['sourceName'], fallback: 'Firestore'),
      sourceUrl: _stringValue(json['sourceUrl']),
      accentColor: _parseColor(json['accentColor']),
      estimatedMinutes:
          (json['estimatedMinutes'] as num?)?.toInt() ??
          _estimateMinutes(pages),
      pageCount:
          (json['pageCount'] as num?)?.toInt() ??
          (rawPages is num ? rawPages.toInt() : pages.length),
      language: _stringValue(json['language'], fallback: 'Español'),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      aiEnabled: json['aiEnabled'] == true,
      summary: _stringValue(json['summary']),
      keywords: keywords,
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
    final lower = _normalized(audience);
    if (const {
      'ninos',
      'children',
      'kids',
      'infantil',
      'child',
    }.contains(lower)) {
      return 'kids';
    }
    if (const {'adultos', 'adulto', 'adult', 'adults'}.contains(lower)) {
      return 'adult';
    }
    return 'General';
  }

  static List<String> _stringList(Object? value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static String _normalized(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
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
