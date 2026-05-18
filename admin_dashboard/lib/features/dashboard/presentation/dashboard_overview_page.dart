import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/responsive/responsive_value.dart';
import '../../../shared/animations/entrance_animations.dart';
import '../../../shared/components/metric_card.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/skeleton.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/activity_table.dart';
import '../widgets/ops_health_panel.dart';
import '../widgets/reading_chart.dart';
import '../widgets/segment_chart.dart';

class DashboardOverviewPage extends ConsumerWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: snapshot.when(
        loading: () => const _DashboardSkeleton(),
        error: (error, _) => Center(child: Text('Unable to load dashboard metrics: $error')),
        data: (data) {
          final columns = responsiveValue<int>(context, tablet: 2, laptop: 2, desktop: 4, wide: 4);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: AppSpacing.page,
                sliver: SliverList.list(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Dashboard overview', style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          Text('Monitor platform growth, reading engagement, token economics, and operational risk.', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                        ]),
                      ),
                      const _StatusPill(),
                    ],
                  ).enterpriseFade(),
                  const SizedBox(height: AppSpacing.lg),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.kpis.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: 236),
                    itemBuilder: (context, index) => MetricCard(metric: data.kpis[index]).enterpriseFade(delay: Duration(milliseconds: index * 55)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(builder: (context, constraints) {
                    final compact = constraints.maxWidth < 1080;
                    final left = ReadingChart(points: data.reading).enterpriseFade(delay: const Duration(milliseconds: 140));
                    final right = Column(children: [SegmentChart(segments: data.segments), const SizedBox(height: 16), const OpsHealthPanel()]).enterpriseFade(delay: const Duration(milliseconds: 180));
                    if (compact) return Column(children: [left, const SizedBox(height: 16), right]);
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 7, child: left), const SizedBox(width: 16), Expanded(flex: 3, child: right)]);
                  }),
                  const SizedBox(height: AppSpacing.lg),
                  ActivityTable(activities: data.activities).enterpriseFade(delay: const Duration(milliseconds: 220)),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: .22))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('All systems operational', style: context.text.labelMedium?.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.page,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SkeletonBlock(width: 280, height: 32),
        const SizedBox(height: 12),
        const SkeletonBlock(width: 520),
        const SizedBox(height: 24),
        GridView.count(shrinkWrap: true, crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.35, children: const [SkeletonBlock(height: 220), SkeletonBlock(height: 220), SkeletonBlock(height: 220), SkeletonBlock(height: 220)]),
        const SizedBox(height: 24),
        const Expanded(child: SkeletonBlock()),
      ]),
    );
  }
}
