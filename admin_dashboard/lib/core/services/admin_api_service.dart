import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/dashboard/models/admin_models.dart';

class AdminApiException implements Exception {
  const AdminApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null ? message : '$message (HTTP $statusCode)';
}

class AdminApiService {
  AdminApiService({http.Client? client, this.authToken = const String.fromEnvironment('ADMIN_AUTH_TOKEN')}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment('ADMIN_API_BASE_URL', defaultValue: 'https://book-api-nu-six.vercel.app');

  final http.Client _client;
  final String authToken;

  Future<List<AdminBook>> fetchBooks() async {
    final payload = await _get('/api/books', authenticated: false);
    return _list(payload, preferredKey: 'books').map(AdminBook.fromJson).toList();
  }

  Future<AdminBook> createBook(AdminBook book) async {
    final payload = await _send('POST', '/api/books', body: book.toJson());
    return AdminBook.fromJson(payload);
  }

  Future<AdminBook> updateBook(AdminBook book) async {
    final payload = await _send('PATCH', '/api/books/${Uri.encodeComponent(book.id)}', body: book.toJson());
    return AdminBook.fromJson(payload);
  }

  Future<void> deleteBook(String bookId) async {
    await _send('DELETE', '/api/books/${Uri.encodeComponent(bookId)}');
  }

  Future<List<AdminUser>> fetchUsers() async {
    final payload = await _get('/api/admin/users');
    return _list(payload).map(AdminUser.fromJson).toList();
  }

  Future<AdminUser> patchUser(String docId, Map<String, dynamic> values) async {
    final payload = await _send('PATCH', '/api/admin/users/${Uri.encodeComponent(docId)}', body: values);
    return AdminUser.fromJson(payload);
  }

  Future<List<TokenTransaction>> fetchTokenTransactions() async {
    final payload = await _get('/api/admin/token_transactions');
    final rows = List<Map<String, dynamic>>.from(_list(payload))..sort((a, b) => _sortDate(b).compareTo(_sortDate(a)));
    return rows.map(TokenTransaction.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> fetchIaChats() async {
    final payload = await _get('/api/admin/ia_chats');
    return _list(payload);
  }

  Future<Map<String, dynamic>> _get(String path, {bool authenticated = true}) => _send('GET', path, authenticated: authenticated);

  Future<Map<String, dynamic>> _send(String method, String path, {Map<String, dynamic>? body, bool authenticated = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && authToken.trim().isNotEmpty) headers['Authorization'] = 'Bearer ${authToken.trim()}';

    final requestBody = body == null ? null : jsonEncode(body);
    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(uri, headers: headers, body: requestBody),
      'PATCH' => await _client.patch(uri, headers: headers, body: requestBody),
      'DELETE' => await _client.delete(uri, headers: headers),
      _ => throw ArgumentError('Unsupported method $method'),
    };

    if (response.statusCode == 204) return const {};
    final decoded = response.body.isEmpty ? const <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map && decoded['error'] != null ? decoded['error'].toString() : 'No se pudo completar $method $path';
      throw AdminApiException(message, statusCode: response.statusCode);
    }
    if (decoded is Map<String, dynamic>) return decoded;
    throw const AdminApiException('La API devolvió una respuesta inesperada.');
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> payload, {String preferredKey = 'items'}) {
    final dynamic value = payload[preferredKey] ?? payload['items'] ?? payload['books'] ?? payload['transactions'] ?? payload['data'];
    if (value is List) return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    return const [];
  }

  DateTime _sortDate(Map<String, dynamic> json) {
    final tx = TokenTransaction.fromJson(json);
    return tx.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
