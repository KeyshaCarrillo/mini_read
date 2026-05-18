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

  Future<void> deleteBook(String bookId) async {
    await _api.deleteBook(bookId);
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
}
