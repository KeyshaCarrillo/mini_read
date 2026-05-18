import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/components/premium_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../models/admin_models.dart';

class SegmentChart extends StatefulWidget {
  const SegmentChart({super.key, required this.segments});
  final List<SegmentMetric> segments;

  @override
  State<SegmentChart> createState() => _SegmentChartState();
}

class _SegmentChartState extends State<SegmentChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Segmentación por edades', subtitle: 'Niños, adolescentes y adultos'),
          const SizedBox(height: 24),
          SizedBox(
            height: 210,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 54,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(touchCallback: (event, response) {
                  setState(() => touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1);
                }),
                sections: [
                  for (var i = 0; i < widget.segments.length; i++)
                    PieChartSectionData(
                      value: widget.segments[i].value,
                      color: widget.segments[i].color,
                      radius: touchedIndex == i ? 36 : 27,
                      title: touchedIndex == i ? '${widget.segments[i].value.toStringAsFixed(0)}%' : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                ],
              ),
              duration: const Duration(milliseconds: 350),
            ),
          ),
          const SizedBox(height: 18),
          ...widget.segments.map((segment) => Padding(
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
