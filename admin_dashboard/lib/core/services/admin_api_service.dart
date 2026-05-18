import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/admin/models/admin_entities.dart';

class AdminApiService {
  AdminApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://book-api-nu-six.vercel.app';

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<AdminBook>> fetchBooks() async {
    final response = await _client.get(_uri('/api/books'));
    final data = _decodeResponse(response);
    return _asList(data).map(AdminBook.fromJson).toList();
  }

  Future<AdminBook> createBook(AdminBook book) async {
    final response = await _client.post(
      _uri('/api/books'),
      headers: _jsonHeaders,
      body: jsonEncode(book.toCreateJson()),
    );
    final data = _decodeResponse(response);
    if (data is Map<String, dynamic>) return AdminBook.fromJson(data);
    return book;
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> payload) async {
    final response = await _client.patch(
      _uri('/api/books/$bookId'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    _decodeResponse(response);
  }

  Future<void> deleteBook(String bookId) async {
    final response = await _client.delete(_uri('/api/books/$bookId'));
    _decodeResponse(response);
  }

  Future<List<AdminUser>> fetchUsers() async {
    final response = await _client.get(_uri('/api/admin/users'));
    final data = _decodeResponse(response);
    return _asList(data).map(AdminUser.fromJson).toList();
  }

  Future<void> patchUser(String docId, Map<String, dynamic> payload) async {
    final response = await _client.patch(
      _uri('/api/admin/users/$docId'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    _decodeResponse(response);
  }

  Future<List<TokenTransaction>> fetchTokenTransactions() async {
    final response = await _client.get(_uri('/api/admin/token_transactions'));
    final data = _decodeResponse(response);
    final transactions = _asList(data).map(TokenTransaction.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  Object? _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdminApiException('API ${response.statusCode}: ${response.body}');
    }
    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    if (data is List) {
      return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (data is Map) {
      for (final key in ['data', 'items', 'results', 'books', 'users', 'transactions']) {
        final value = data[key];
        if (value is List) {
          return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
      return [Map<String, dynamic>.from(data)];
    }
    return const [];
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};
}

class AdminApiException implements Exception {
  const AdminApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
