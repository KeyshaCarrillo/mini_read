import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/components/premium_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../models/admin_models.dart';

class ReadingChart extends StatelessWidget {
  const ReadingChart({super.key, required this.points});
  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Reading engagement',
            subtitle: 'Sessions and completed chapters over the last 7 days',
            trailing: SegmentedButton<String>(
              segments: const [ButtonSegment(value: '7d', label: Text('7d')), ButtonSegment(value: '30d', label: Text('30d')), ButtonSegment(value: '90d', label: Text('90d'))],
              selected: const {'7d'},
              onSelectionChanged: (_) {},
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 310,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 110,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.theme.dividerColor, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, interval: 25, getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 10), child: Text(points[index].label, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)));
                  })),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem('${spot.y.toStringAsFixed(0)}k events', TextStyle(color: context.colors.surface, fontWeight: FontWeight.w700))).toList(),
                  ),
                ),
                lineBarsData: [
                  _line(context.colors.primary, points.map((e) => e.value).toList()),
                  _line(const Color(0xFF10B981), points.map((e) => e.secondaryValue).toList()),
                ],
              ),
              duration: const Duration(milliseconds: 700),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(Color color, List<double> values) => LineChartBarData(
        spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
        isCurved: true,
        preventCurveOverShooting: true,
        color: color,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withValues(alpha: .18), color.withValues(alpha: 0)])),
      );
}
