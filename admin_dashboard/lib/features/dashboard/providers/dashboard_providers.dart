import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/admin_metrics_service.dart';

final adminMetricsServiceProvider = Provider<AdminMetricsService>((ref) => AdminMetricsService());
final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((ref) {
  return ref.watch(adminMetricsServiceProvider).loadSnapshot();
});
