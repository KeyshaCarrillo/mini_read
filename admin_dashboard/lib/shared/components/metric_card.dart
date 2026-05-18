import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../features/dashboard/models/admin_models.dart';
import '../extensions/context_extensions.dart';
import '../widgets/hoverable_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.metric});
  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    final positive = metric.delta >= 0;
    return HoverableCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: metric.color.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)),
                child: Icon(metric.icon, color: metric.color, size: 18),
              ),
              const Spacer(),
              Icon(positive ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 17, color: positive ? const Color(0xFF10B981) : const Color(0xFFF43F5E)),
              const SizedBox(width: 4),
              Text(signedPercent(metric.delta), style: TextStyle(color: positive ? const Color(0xFF10B981) : const Color(0xFFF43F5E), fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 18),
          Text(metric.label, style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(metric.value, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.6)),
          const SizedBox(height: 8),
          Text(metric.deltaLabel, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (var i = 0; i < metric.trend.length; i++) FlSpot(i.toDouble(), metric.trend[i])],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: metric.color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [metric.color.withValues(alpha: .16), metric.color.withValues(alpha: 0)])),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 450),
            ),
          ),
        ],
      ),
    );
  }
}
