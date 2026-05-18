// lib/features/library/data/datasources/book_api_datasource.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/book.dart';

class BookApiDataSource {
  final http.Client client;
  final String baseUrl;

  const BookApiDataSource({required this.client, required this.baseUrl});

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Future<List<Book>> getBooks() async {
    if (!isConfigured) return const [];

    final response = await client.get(Uri.parse('${_cleanBaseUrl()}/books'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo cargar el catalogo de libros.');
    }

    final decoded = jsonDecode(response.body);
    final rawBooks = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
        ? decoded['books']
        : null;

    if (rawBooks is! List) return const [];

    return rawBooks
        .whereType<Map<String, dynamic>>()
        .map(_bookFromJson)
        .toList(growable: false);
  }

  Future<Book> getBookById(String bookId) async {
    final response = await client.get(
      Uri.parse('${_cleanBaseUrl()}/books/$bookId'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo cargar el libro $bookId.');
    }

    return _bookFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Book _bookFromJson(Map<String, dynamic> json) {
    final pages = (json['pages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_pageFromJson)
        .toList(growable: false);

    return Book(
      id: json['id']?.toString() ?? json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sin titulo',
      author: json['author']?.toString() ?? 'Autor desconocido',
      category: json['category']?.toString() ?? 'General',
      audience: json['audience']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      sourceName: json['sourceName']?.toString() ?? 'API de libros',
      sourceUrl: json['sourceUrl']?.toString() ?? '',
      accentColor: _parseColor(json['accentColor']),
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 10,
      hasImmersiveImages:
          json['hasImmersiveImages'] == true ||
          pages.any((page) => page.imageUrl != null),
      pages: pages,
    );
  }

  BookPage _pageFromJson(Map<String, dynamic> json) {
    return BookPage(
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      title: json['title']?.toString() ?? 'Pagina',
      body: json['text']?.toString() ?? json['body']?.toString() ?? '',
      illustration: json['illustration']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  int _parseColor(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll('#', '').replaceAll('0x', '');
      final withAlpha = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
      return int.tryParse(withAlpha, radix: 16) ?? 0xFF1B263B;
    }
    return 0xFF1B263B;
  }

  String _cleanBaseUrl() {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }
}
