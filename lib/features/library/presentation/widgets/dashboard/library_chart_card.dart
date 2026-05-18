import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/book.dart';

class LibraryChartCard extends StatelessWidget {
  final List<Book> books;

  const LibraryChartCard({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final buckets = _categoryBuckets(books);
    final pointCount = buckets.length < 7 ? buckets.length : 7;
    final spots = List.generate(
      pointCount < 1 ? 1 : pointCount,
      (index) => FlSpot(
        index.toDouble(),
        (buckets.values.elementAt(index) + index + 2).toDouble(),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Engagement de lectura', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Tendencia estimada por disponibilidad y categorías', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.show_chart_rounded),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 230,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(color: scheme.outline.withValues(alpha: 0.45), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) => Padding(padding: const EdgeInsets.only(top: 8), child: Text('S${value.toInt() + 1}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11))))),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: scheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: scheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _categoryBuckets(List<Book> books) {
    final buckets = <String, int>{};
    for (final book in books) {
      buckets.update(book.category, (value) => value + 1, ifAbsent: () => 1);
    }
    if (buckets.isEmpty) return {'Sin datos': 1};
    return buckets;
  }
}
