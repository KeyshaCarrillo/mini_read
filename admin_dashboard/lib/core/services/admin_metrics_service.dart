import 'package:flutter/material.dart';

import '../../features/dashboard/models/admin_models.dart';
import '../theme/app_colors.dart';

class AdminMetricsService {
  Future<DashboardSnapshot> loadSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const DashboardSnapshot(
      kpis: [
        KpiMetric(label: 'Active readers', value: '128.4K', delta: 12.8, deltaLabel: 'vs. last 30d', icon: Icons.auto_stories_outlined, color: AdminColors.indigo600, trend: [28, 34, 31, 43, 48, 52, 61]),
        KpiMetric(label: 'Books completed', value: '42,918', delta: 8.4, deltaLabel: 'completion rate up', icon: Icons.done_all_rounded, color: AdminColors.emerald500, trend: [18, 22, 29, 31, 37, 39, 44]),
        KpiMetric(label: 'Token usage', value: '9.7M', delta: -3.2, deltaLabel: 'cost optimized', icon: Icons.generating_tokens_outlined, color: AdminColors.blue600, trend: [62, 58, 54, 49, 52, 47, 45]),
        KpiMetric(label: 'Open incidents', value: '3', delta: 1.1, deltaLabel: '2 require review', icon: Icons.health_and_safety_outlined, color: AdminColors.amber500, trend: [4, 3, 5, 4, 2, 3, 3]),
      ],
      reading: [
        ChartPoint('Mon', 42, 28), ChartPoint('Tue', 58, 35), ChartPoint('Wed', 53, 41), ChartPoint('Thu', 74, 52), ChartPoint('Fri', 88, 63), ChartPoint('Sat', 69, 49), ChartPoint('Sun', 94, 71),
      ],
      segments: [
        SegmentMetric(name: 'Free', value: 46, color: AdminColors.slate500),
        SegmentMetric(name: 'Plus', value: 34, color: AdminColors.indigo600),
        SegmentMetric(name: 'Enterprise', value: 20, color: AdminColors.emerald500),
      ],
      activities: [
        ActivityRecord(user: 'Ariana Vidal', email: 'ariana@acme.co', action: 'Upgraded workspace to Enterprise', status: 'Success', plan: 'Enterprise', time: '2 min ago', initials: 'AV'),
        ActivityRecord(user: 'Marco Chen', email: 'marco@northstar.io', action: 'Exported reading report', status: 'Processing', plan: 'Plus', time: '11 min ago', initials: 'MC'),
        ActivityRecord(user: 'Nora Patel', email: 'nora@lumen.dev', action: 'Triggered suspicious login review', status: 'Review', plan: 'Free', time: '18 min ago', initials: 'NP'),
        ActivityRecord(user: 'Evan Brooks', email: 'evan@atlas.ai', action: 'Created admin token policy', status: 'Success', plan: 'Enterprise', time: '27 min ago', initials: 'EB'),
        ActivityRecord(user: 'Lucia Rivera', email: 'lucia@papertrail.app', action: 'Invited 12 educators', status: 'Success', plan: 'Plus', time: '41 min ago', initials: 'LR'),
      ],
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({required this.kpis, required this.reading, required this.segments, required this.activities});
  final List<KpiMetric> kpis;
  final List<ChartPoint> reading;
  final List<SegmentMetric> segments;
  final List<ActivityRecord> activities;
}
