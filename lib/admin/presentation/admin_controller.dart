import 'package:flutter/foundation.dart';

import '../data/admin_api_service.dart';
import '../domain/admin_models.dart';

enum AdminSection { dashboard, users, tokens, settings }

class MonthlyTokenUsage {
  final String label;
  final int ads;
  final int ai;

  const MonthlyTokenUsage({
    required this.label,
    required this.ads,
    required this.ai,
  });
}

class AdminController extends ChangeNotifier {
  final AdminApiService api;

  AdminController({required this.api});

  AdminSection section = AdminSection.dashboard;
  bool isDarkMode = false;
  bool isLoading = false;
  String? error;

  List<AdminBook> books = const [];
  List<AdminUser> users = const [];
  List<TokenTransaction> transactions = const [];
  List<AiChatLog> aiChats = const [];

  int get totalBooks => books.length;
  int get totalUsers => users.length;
  int get premiumUsers => users.where((user) => user.isPremium).length;
  int get tokenBalance => transactions.fold<int>(0, (sum, tx) => sum + tx.amount);
  bool get hasInventoryWarning => books.length < 10;

  List<MonthlyTokenUsage> get monthlyUsage {
    final now = DateTime.now();
    final months = List<DateTime>.generate(
      6,
      (index) => DateTime(now.year, now.month - (5 - index)),
    );

    return months.map((month) {
      var ads = 0;
      var ai = 0;
      for (final tx in transactions) {
        final date = tx.createdAt;
        if (date == null || date.year != month.year || date.month != month.month) {
          continue;
        }
        if (tx.isAiQuery) ai += tx.amount.abs();
        if (tx.isRewardAd) ads += tx.amount.abs();
      }
      return MonthlyTokenUsage(
        label: _monthLabel(month.month),
        ads: ads,
        ai: ai,
      );
    }).toList(growable: false);
  }

  void selectSection(AdminSection value) {
    section = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final loadedBooks = await api.fetchBooks();
      List<AdminUser> loadedUsers = const [];
      List<TokenTransaction> loadedTransactions = const [];
      List<AiChatLog> loadedAiChats = const [];
      try {
        loadedUsers = await api.fetchUsers();
        loadedTransactions = await api.fetchTokenTransactions();
        loadedAiChats = await api.fetchAiChats();
      } catch (adminError) {
        error = adminError.toString().replaceFirst('Exception: ', '');
      }
      books = loadedBooks;
      users = loadedUsers;
      transactions = loadedTransactions;
      aiChats = loadedAiChats;
    } catch (loadError) {
      error = loadError.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook({
    required AdminBook book,
    required String title,
    required String category,
    required int pagesCount,
  }) async {
    final pages = List.generate(
      pagesCount,
      (index) => {
        'pageNumber': index + 1,
        'title': 'Pagina ${index + 1}',
        'text': 'Contenido actualizado desde administracion.',
      },
    );
    await api.updateBook(book.id, {
      'title': title.trim(),
      'category': category.trim().isEmpty ? book.category : category.trim(),
      'pages': pages,
      'estimatedMinutes': pagesCount.clamp(1, 999),
    });
    await refresh();
  }

  Future<void> deleteBook(AdminBook book) async {
    await api.deleteBook(book.id);
    await refresh();
  }

  Future<void> createBook({
    required String id,
    required String title,
    required String category,
    required int pagesCount,
  }) async {
    final pages = List.generate(
      pagesCount,
      (index) => {
        'pageNumber': index + 1,
        'title': 'Pagina ${index + 1}',
        'text': 'Contenido pendiente de cargar desde administracion.',
      },
    );
    await api.createBook({
      if (id.trim().isNotEmpty) 'id': id.trim(),
      'title': title.trim(),
      'category': category.trim().isEmpty ? 'General' : category.trim(),
      'audience': 'Administradores',
      'pages': pages,
      'estimatedMinutes': pagesCount.clamp(1, 999),
      'accentColor': '#000666',
    });
    await refresh();
  }

  Future<void> makePremium(AdminUser user) async {
    await api.updateUser(user.id, {
      'isPremium': true,
      'premium': true,
      'subscription': 'premium',
    });
    await refresh();
  }

  Future<void> toggleBan(AdminUser user) async {
    await api.updateUser(user.id, {
      'isBanned': !user.isBanned,
      'banned': !user.isBanned,
    });
    await refresh();
  }

  String _monthLabel(int month) {
    const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return labels[month - 1];
  }
}
