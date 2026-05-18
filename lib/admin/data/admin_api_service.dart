import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;

import '../domain/admin_models.dart';

class AdminApiService {
  static const String defaultBaseUrl = 'https://book-api-nu-six.vercel.app/api';

  final http.Client client;
  final fb.FirebaseAuth auth;
  final String baseUrl;

  const AdminApiService({
    required this.client,
    required this.auth,
    this.baseUrl = defaultBaseUrl,
  });

  Future<List<AdminBook>> fetchBooks() async {
    final decoded = await _request('GET', '/books', requiresAdmin: false);
    final raw = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
        ? decoded['books']
        : null;
    return _list(raw, AdminBook.fromJson);
  }

  Future<AdminBook> createBook(Map<String, dynamic> payload) async {
    final decoded = await _request('POST', '/books', body: payload);
    return AdminBook.fromJson(decoded as Map<String, dynamic>);
  }

  Future<AdminBook> updateBook(
    String bookId,
    Map<String, dynamic> payload,
  ) async {
    final decoded = await _request('PATCH', '/books/$bookId', body: payload);
    return AdminBook.fromJson(decoded as Map<String, dynamic>);
  }

  Future<void> deleteBook(String bookId) async {
    await _request('DELETE', '/books/$bookId');
  }

  Future<List<AdminUser>> fetchUsers() async {
    final decoded = await _request('GET', '/admin/users');
    final raw = decoded is Map<String, dynamic> ? decoded['items'] : decoded;
    return _list(raw, AdminUser.fromJson);
  }

  Future<AdminUser> updateUser(
    String docId,
    Map<String, dynamic> payload,
  ) async {
    final decoded = await _request('PATCH', '/admin/users/$docId', body: payload);
    return AdminUser.fromJson(decoded as Map<String, dynamic>);
  }

  Future<List<TokenTransaction>> fetchTokenTransactions() async {
    final decoded = await _request('GET', '/admin/token_transactions');
    final raw = decoded is Map<String, dynamic> ? decoded['items'] : decoded;
    return _list(raw, TokenTransaction.fromJson)..sort((a, b) {
      final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
  }

  Future<List<AiChatLog>> fetchAiChats() async {
    final decoded = await _request('GET', '/admin/ia_chats');
    final raw = decoded is Map<String, dynamic> ? decoded['items'] : decoded;
    return _list(raw, AiChatLog.fromJson);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAdmin = true,
  }) async {
    final uri = Uri.parse('${_cleanBaseUrl()}$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';

    final user = auth.currentUser;
    final token = await user?.getIdToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';

    if (requiresAdmin && token == null) {
      throw Exception('Inicia sesion con una cuenta administradora para consumir Firebase.');
    }

    final response = switch (method) {
      'GET' => await client.get(uri, headers: headers),
      'POST' => await client.post(uri, headers: headers, body: jsonEncode(body)),
      'PATCH' => await client.patch(uri, headers: headers, body: jsonEncode(body)),
      'DELETE' => await client.delete(uri, headers: headers),
      _ => throw UnsupportedError('Metodo HTTP no soportado: $method'),
    };

    if (response.statusCode == 204) return null;
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString()
          : null;
      throw Exception(message ?? 'Error ${response.statusCode} en $path.');
    }
    return decoded;
  }

  List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) mapper) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList(growable: false);
  }

  String _cleanBaseUrl() => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}
