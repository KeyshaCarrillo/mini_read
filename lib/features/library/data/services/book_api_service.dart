import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book_model.dart';

class BookApiService {
  static const String defaultEndpoint =
      'https://book-api-nu-six.vercel.app/api/books';

  final http.Client client;
  final String endpoint;

  const BookApiService({required this.client, this.endpoint = defaultEndpoint});

  Future<List<BookModel>> fetchBooks() async {
    final response = await client.get(Uri.parse(endpoint));

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
        .map(BookModel.fromJson)
        .where((book) => book.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<BookModel> fetchBookById(String bookId) async {
    final response = await client.get(Uri.parse('$endpoint/$bookId'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo cargar el libro $bookId.');
    }

    final decoded = jsonDecode(response.body);
    final rawBook = decoded is Map<String, dynamic> && decoded['book'] is Map
        ? decoded['book']
        : decoded;

    return BookModel.fromJson(Map<String, dynamic>.from(rawBook as Map));
  }
}
