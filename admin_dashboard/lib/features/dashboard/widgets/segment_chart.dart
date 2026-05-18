import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/components/premium_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../models/admin_models.dart';

class SegmentChart extends StatelessWidget {
  const SegmentChart({super.key, required this.segments});
  final List<SegmentMetric> segments;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Plan mix', subtitle: 'Revenue-facing account distribution'),
          const SizedBox(height: 24),
          SizedBox(
            height: 210,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 58,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(enabled: true),
                sections: [
                  for (final segment in segments)
                    PieChartSectionData(value: segment.value, color: segment.color, radius: 26, showTitle: false),
                ],
              ),
              duration: const Duration(milliseconds: 700),
            ),
          ),
          const SizedBox(height: 18),
          ...segments.map((segment) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: segment.color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(segment.name, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                  Text('${segment.value.toStringAsFixed(0)}%', style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                ]),
              )),
        ],
      ),
    );
  }
}
