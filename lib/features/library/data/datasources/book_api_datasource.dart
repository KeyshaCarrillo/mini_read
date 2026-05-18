import 'package:http/http.dart' as http;

import '../../domain/entities/book.dart';
import '../services/book_api_service.dart';

class BookApiDataSource {
  final BookApiService service;

  BookApiDataSource({required http.Client client, required String baseUrl})
    : service = BookApiService(
        client: client,
        endpoint: _endpointFrom(baseUrl),
      );

  Future<List<Book>> getBooks() {
    return service.fetchBooks();
  }

  Future<Book> getBookById(String bookId) {
    return service.fetchBookById(bookId);
  }

  static String _endpointFrom(String value) {
    final trimmed = value.trim().replaceFirst(RegExp(r'/$'), '');
    if (trimmed.isEmpty) return BookApiService.defaultEndpoint;
    if (trimmed.endsWith('/books')) return trimmed;
    return '$trimmed/books';
  }
}
