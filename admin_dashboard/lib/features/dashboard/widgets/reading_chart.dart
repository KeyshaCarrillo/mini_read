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
    final maxValue = points.fold<double>(10, (max, point) => [max, point.value, point.secondaryValue].reduce((a, b) => a > b ? a : b));
    return PremiumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Consumo mensual de tokens',
            subtitle: 'Comparativa Firebase: anuncios vs consultas de IA desde token_transactions',
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 310,
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 10 : maxValue * 1.25,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.theme.dividerColor, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 10), child: Text(points[index].label, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)));
                  })),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final source = rodIndex == 0 ? 'Anuncios' : 'IA';
                      return BarTooltipItem('$source\n${rod.toY.toStringAsFixed(0)} tokens', TextStyle(color: context.colors.surface, fontWeight: FontWeight.w800));
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    BarChartGroupData(x: i, barsSpace: 6, barRods: [
                      BarChartRodData(toY: points[i].value, width: 18, borderRadius: BorderRadius.circular(6), color: context.colors.primary),
                      BarChartRodData(toY: points[i].secondaryValue, width: 18, borderRadius: BorderRadius.circular(6), color: const Color(0xFFFED488)),
                    ]),
                ],
              ),
              duration: const Duration(milliseconds: 700),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _Legend(color: context.colors.primary, label: 'Anuncios'),
            const SizedBox(width: 16),
            const _Legend(color: Color(0xFFFED488), label: 'Consultas IA'),
          ]),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999))),
      const SizedBox(width: 8),
      Text(label, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}
