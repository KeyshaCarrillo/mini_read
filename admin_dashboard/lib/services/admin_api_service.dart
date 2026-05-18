import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/admin_user.dart';
import '../models/book.dart';
import '../models/ia_chat.dart';
import '../models/token_transaction.dart';

class AdminApiException implements Exception {
  final String message;
  final int? statusCode;

  const AdminApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AdminApiService {
  final String baseUrl;
  final http.Client _client;

  AdminApiService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<Map<String, String>> _headers({bool authRequired = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (!authRequired) return headers;

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      throw const AdminApiException('Inicia sesion para continuar.', 401);
    }
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    var message = 'Error ${response.statusCode} al llamar la API.';
    try {
      final body = jsonDecode(response.body);
      message = '${body['error'] ?? message}';
    } catch (_) {}
    throw AdminApiException(message, response.statusCode);
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get(
      _uri('/api/me'),
      headers: await _headers(),
    );
    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  Future<List<Book>> getBooks() async {
    final response = await _client.get(
      _uri('/api/books'),
      headers: await _headers(authRequired: false),
    );
    final body = Map<String, dynamic>.from(_decode(response) as Map);
    final books = (body['books'] as List? ?? const []);
    return books
        .map((item) => Book.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Book> createBook(Book book) async {
    final response = await _client.post(
      _uri('/api/books'),
      headers: await _headers(),
      body: jsonEncode(book.toCreateJson()),
    );
    return Book.fromJson(Map<String, dynamic>.from(_decode(response) as Map));
  }

  Future<void> deleteBook(String bookId) async {
    final response = await _client.delete(
      _uri('/api/books/$bookId'),
      headers: await _headers(),
    );
    _decode(response);
  }

  Future<List<AdminUser>> getUsers() async {
    final body = await _getAdminCollection('users');
    return body.map((item) => AdminUser.fromJson(item)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<TokenTransaction>> getTokenTransactions() async {
    final body = await _getAdminCollection('token_transactions');
    return body.map((item) => TokenTransaction.fromJson(item)).toList()
      ..sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
  }

  Future<List<IaChat>> getIaChats() async {
    final body = await _getAdminCollection('ia_chats');
    return body.map((item) => IaChat.fromJson(item)).toList()..sort((a, b) {
      final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
  }

  Future<AdminUser> patchUser(
    String docId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.patch(
      _uri('/api/admin/users/$docId'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    return AdminUser.fromJson(
      Map<String, dynamic>.from(_decode(response) as Map),
    );
  }

  Future<List<Map<String, dynamic>>> _getAdminCollection(
    String collection,
  ) async {
    final response = await _client.get(
      _uri('/api/admin/$collection'),
      headers: await _headers(),
    );
    final body = Map<String, dynamic>.from(_decode(response) as Map);
    return (body['items'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
