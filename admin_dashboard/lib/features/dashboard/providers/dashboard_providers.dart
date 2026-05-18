import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/admin_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/admin_models.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) => AdminApiService());

final booksProvider = FutureProvider<List<AdminBook>>((ref) => ref.watch(adminApiServiceProvider).fetchBooks());
final usersProvider = FutureProvider<List<AdminUser>>((ref) => ref.watch(adminApiServiceProvider).fetchUsers());
final tokenTransactionsProvider = FutureProvider<List<TokenTransaction>>((ref) => ref.watch(adminApiServiceProvider).fetchTokenTransactions());
final iaChatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) => ref.watch(adminApiServiceProvider).fetchIaChats());

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final service = ref.watch(adminApiServiceProvider);
  final booksFuture = service.fetchBooks();
  final usersFuture = service.fetchUsers();
  final transactionsFuture = service.fetchTokenTransactions();

  final results = await Future.wait<dynamic>([booksFuture, usersFuture, transactionsFuture]);
  final books = results[0] as List<AdminBook>;
  final users = results[1] as List<AdminUser>;
  final transactions = results[2] as List<TokenTransaction>;

  return DashboardSnapshot.fromData(books: books, users: users, transactions: transactions);
});

class DashboardSnapshot {
  const DashboardSnapshot({required this.kpis, required this.reading, required this.segments, required this.activities, required this.books, required this.users, required this.transactions});

  final List<KpiMetric> kpis;
  final List<ChartPoint> reading;
  final List<SegmentMetric> segments;
  final List<ActivityRecord> activities;
  final List<AdminBook> books;
  final List<AdminUser> users;
  final List<TokenTransaction> transactions;

  factory DashboardSnapshot.fromData({required List<AdminBook> books, required List<AdminUser> users, required List<TokenTransaction> transactions}) {
    final premiumUsers = users.where((user) => user.isPremium).length;
    final tokenTotal = transactions.fold<int>(0, (total, tx) => total + tx.amount.abs());
    final reading = _monthlyTokenPoints(transactions);
    final activities = transactions.take(8).map((tx) {
      final amount = tx.amount >= 0 ? '+${tx.amount}' : tx.amount.toString();
      return ActivityRecord(
        user: tx.user,
        email: tx.id,
        action: '${tx.rewardType} · $amount tokens',
        status: tx.amount >= 0 ? 'Success' : 'Review',
        plan: tx.type,
        time: _relative(tx.createdAt),
        initials: _initials(tx.user),
      );
    }).toList();

    return DashboardSnapshot(
      books: books,
      users: users,
      transactions: transactions,
      kpis: [
        KpiMetric(label: 'Libros en Firebase', value: books.length.toString(), delta: books.length >= 10 ? 12 : -18, deltaLabel: books.length >= 10 ? 'Inventario suficiente' : 'Faltan libros para el demo', icon: Icons.auto_stories_outlined, color: AdminColors.deepBlue, trend: _trendFromCount(books.length)),
        KpiMetric(label: 'Usuarios registrados', value: users.length.toString(), delta: users.isEmpty ? -7 : 9, deltaLabel: 'Colección users', icon: Icons.group_outlined, color: AdminColors.emerald500, trend: _trendFromCount(users.length)),
        KpiMetric(label: 'Tokens auditados', value: tokenTotal.toString(), delta: tokenTotal == 0 ? -4 : 6, deltaLabel: 'token_transactions', icon: Icons.generating_tokens_outlined, color: AdminColors.gold, trend: _trendFromTransactions(transactions)),
        KpiMetric(label: 'Cuentas premium', value: premiumUsers.toString(), delta: premiumUsers == 0 ? -2 : 14, deltaLabel: 'Control de suscripción', icon: Icons.workspace_premium_outlined, color: AdminColors.amber500, trend: _trendFromCount(premiumUsers)),
      ],
      reading: reading,
      segments: const [
        SegmentMetric(name: 'Niños', value: 60, color: AdminColors.deepBlue),
        SegmentMetric(name: 'Adolescentes', value: 25, color: AdminColors.gold),
        SegmentMetric(name: 'Adultos', value: 15, color: AdminColors.emerald500),
      ],
      activities: activities,
    );
  }
}

List<ChartPoint> _monthlyTokenPoints(List<TokenTransaction> transactions) {
  final now = DateTime.now();
  return List.generate(6, (index) {
    final date = DateTime(now.year, now.month - 5 + index);
    final monthly = transactions.where((tx) => tx.createdAt != null && tx.createdAt!.year == date.year && tx.createdAt!.month == date.month);
    final ads = monthly.where((tx) => tx.isAd).fold<int>(0, (total, tx) => total + tx.amount.abs());
    final ai = monthly.where((tx) => tx.isAi).fold<int>(0, (total, tx) => total + tx.amount.abs());
    return ChartPoint(_monthLabel(date.month), ads.toDouble(), ai.toDouble());
  });
}

List<double> _trendFromCount(int count) => [1, 2, 3, 4, 5, 6, count.toDouble().clamp(1, 100).toDouble()];

List<double> _trendFromTransactions(List<TokenTransaction> transactions) {
  if (transactions.isEmpty) return const [0, 0, 0, 0, 0, 0, 0];
  return transactions.take(7).map((tx) => tx.amount.abs().toDouble().clamp(1, 100).toDouble()).toList().reversed.toList();
}

String _relative(DateTime? date) {
  if (date == null) return 'Sin fecha';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  return '${diff.inDays} d';
}

String _monthLabel(int month) => const ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'][month - 1];

String _initials(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'TX';
  final parts = trimmed.split(RegExp(r'\s+'));
  return parts.take(2).map((part) => part.substring(0, 1).toUpperCase()).join();
}
