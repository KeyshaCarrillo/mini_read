import 'package:flutter/material.dart';

import '../../../core/services/admin_api_service.dart';
import '../models/admin_entities.dart';

enum AdminModule { dashboard, users, tokens, settings }

class AdminDashboardController extends ChangeNotifier {
  AdminDashboardController({AdminApiService? api}) : _api = api ?? AdminApiService();

  final AdminApiService _api;

  AdminModule selectedModule = AdminModule.dashboard;
  bool isDarkMode = false;
  bool isLoading = false;
  String? errorMessage;

  List<AdminBook> books = const [];
  List<AdminUser> users = const [];
  List<TokenTransaction> tokenTransactions = const [];

  bool get hasBookAlert => books.length < 12;
  int get activeUsers => users.where((user) => !user.isBanned).length;
  int get premiumUsers => users.where((user) => user.isPremium).length;
  int get totalTokens => tokenTransactions.fold<int>(0, (total, item) => total + item.amount.abs());

  List<MonthlyTokenUsage> get monthlyTokenUsage {
    final now = DateTime.now();
    final buckets = <String, ({double ads, double ai})>{};
    for (var offset = 5; offset >= 0; offset--) {
      final date = DateTime(now.year, now.month - offset);
      buckets[_monthKey(date)] = (ads: 0, ai: 0);
    }
    for (final transaction in tokenTransactions) {
      final key = _monthKey(transaction.createdAt);
      if (!buckets.containsKey(key)) continue;
      final current = buckets[key]!;
      final amount = transaction.amount.abs().toDouble();
      buckets[key] = (
        ads: current.ads + (transaction.isAdReward ? amount : 0),
        ai: current.ai + (transaction.isAiQuery || !transaction.isAdReward ? amount : 0),
      );
    }
    return buckets.entries.map((entry) => MonthlyTokenUsage(monthLabel: entry.key, adsTokens: entry.value.ads, aiTokens: entry.value.ai)).toList();
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await _loadAll();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    errorMessage = null;
    notifyListeners();
    await _loadAll();
    notifyListeners();
  }

  void selectModule(AdminModule module) {
    selectedModule = module;
    notifyListeners();
  }

  void toggleTheme(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  Future<void> addBook(AdminBook book) async {
    await _api.createBook(book);
    books = await _api.fetchBooks();
    notifyListeners();
  }

  Future<void> makePremium(AdminUser user) async {
    await _api.patchUser(user.docId, {'plan': 'Premium', 'isPremium': true});
    users = users.map((item) => item.docId == user.docId ? item.copyWith(plan: 'Premium') : item).toList();
    notifyListeners();
  }

  Future<void> banUser(AdminUser user) async {
    await _api.patchUser(user.docId, {'status': 'Banned', 'banned': true});
    users = users.map((item) => item.docId == user.docId ? item.copyWith(status: 'Banned') : item).toList();
    notifyListeners();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait<Object>([
        _api.fetchBooks(),
        _api.fetchUsers(),
        _api.fetchTokenTransactions(),
      ]);
      books = results[0] as List<AdminBook>;
      users = results[1] as List<AdminUser>;
      tokenTransactions = results[2] as List<TokenTransaction>;
    } on Object catch (error) {
      errorMessage = error.toString();
    }
  }

  String _monthKey(DateTime date) {
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return labels[date.month - 1];
  }
}
