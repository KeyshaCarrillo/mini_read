import 'dart:async';

import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../models/book.dart';
import '../models/ia_chat.dart';
import '../models/token_transaction.dart';
import '../services/admin_api_service.dart';

enum AdminSection { dashboard, users, tokens, settings }

class DashboardMetrics {
  final int totalUsers;
  final int premiumUsers;
  final int totalBooks;
  final int tokensInCirculation;
  final int iaQuestions;

  const DashboardMetrics({
    required this.totalUsers,
    required this.premiumUsers,
    required this.totalBooks,
    required this.tokensInCirculation,
    required this.iaQuestions,
  });
}

class AdminController extends ChangeNotifier {
  final AdminApiService _api;

  AdminController(this._api);

  AdminSection section = AdminSection.dashboard;
  bool isDarkMode = false;
  bool isLoading = false;
  String? errorMessage;

  List<Book> books = [];
  List<AdminUser> users = [];
  List<TokenTransaction> transactions = [];
  List<IaChat> iaChats = [];

  static const Duration _searchDebounceDuration = Duration(milliseconds: 280);
  Timer? _searchDebounce;
  String _searchInput = '';
  String _searchQuery = '';
  bool _isSearchPending = false;

  String get searchInput => _searchInput;
  String get searchQuery => _searchQuery;
  bool get isSearchPending => _isSearchPending;
  bool get hasSearchQuery => _searchQuery.isNotEmpty;

  List<Book> get visibleBooks {
    if (_searchQuery.isEmpty) return books;
    return books.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();
      final category = book.category.toLowerCase();
      return title.contains(_searchQuery) ||
          author.contains(_searchQuery) ||
          category.contains(_searchQuery);
    }).toList(growable: false);
  }

  List<AdminUser> get visibleUsers {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final username = user.username.toLowerCase();
      final nickname = user.nickname.toLowerCase();
      return name.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          username.contains(_searchQuery) ||
          nickname.contains(_searchQuery);
    }).toList(growable: false);
  }

  DashboardMetrics get metrics => DashboardMetrics(
    totalUsers: users.length,
    premiumUsers: users.where((user) => user.isPremium).length,
    totalBooks: books.length,
    tokensInCirculation: transactions.fold<int>(
      0,
      (total, transaction) => total + transaction.amount,
    ),
    iaQuestions: iaChats.length,
  );

  void setSection(AdminSection next) {
    section = next;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void updateSearchInput(String value) {
    if (value == _searchInput) return;

    _searchInput = value;
    final normalized = value.trim().toLowerCase();
    _searchDebounce?.cancel();

    if (normalized.isEmpty) {
      final hadQuery = _searchQuery.isNotEmpty || _isSearchPending;
      _searchQuery = '';
      _isSearchPending = false;
      if (hadQuery) {
        notifyListeners();
      }
      return;
    }

    _isSearchPending = true;
    notifyListeners();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      _searchQuery = normalized;
      _isSearchPending = false;
      notifyListeners();
    });
  }

  void clearSearch() {
    if (_searchInput.isEmpty && _searchQuery.isEmpty && !_isSearchPending) {
      return;
    }
    _searchDebounce?.cancel();
    _searchInput = '';
    _searchQuery = '';
    _isSearchPending = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getBooks(),
        _api.getUsers(),
        _api.getTokenTransactions(),
        _api.getIaChats(),
      ]);
      books = results[0] as List<Book>;
      users = results[1] as List<AdminUser>;
      transactions = results[2] as List<TokenTransaction>;
      iaChats = results[3] as List<IaChat>;
    } on AdminApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'No se pudieron cargar los datos administrativos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBooks() async {
    books = await _api.getBooks();
    notifyListeners();
  }

  Future<void> createBook(Book book) async {
    await _api.createBook(book);
    await refreshBooks();
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> payload) async {
    await _api.patchBook(bookId, payload);
    await refreshBooks();
  }

  Future<void> makePremium(AdminUser user) async {
    final updated = await _api.patchUser(user.id, {'isPremium': true});
    _replaceUser(updated);
  }

  Future<void> makeAdmin(AdminUser user) async {
    final updated = await _api.patchUser(user.id, {'role': 'admin'});
    _replaceUser(updated);
  }

  Future<void> toggleBan(AdminUser user) async {
    final updated = await _api.patchUser(user.id, {'banned': !user.banned});
    _replaceUser(updated);
  }

  void _replaceUser(AdminUser updated) {
    users = [for (final user in users) user.id == updated.id ? updated : user];
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
