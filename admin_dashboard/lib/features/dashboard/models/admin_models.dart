import 'package:flutter/material.dart';

class KpiMetric {
  const KpiMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaLabel,
    required this.icon,
    required this.color,
    required this.trend,
  });

  final String label;
  final String value;
  final double delta;
  final String deltaLabel;
  final IconData icon;
  final Color color;
  final List<double> trend;
}

class ChartPoint {
  const ChartPoint(this.label, this.value, this.secondaryValue);
  final String label;
  final double value;
  final double secondaryValue;
}

class ActivityRecord {
  const ActivityRecord({
    required this.user,
    required this.email,
    required this.action,
    required this.status,
    required this.plan,
    required this.time,
    required this.initials,
  });

  final String user;
  final String email;
  final String action;
  final String status;
  final String plan;
  final String time;
  final String initials;
}

class SegmentMetric {
  const SegmentMetric({required this.name, required this.value, required this.color});
  final String name;
  final double value;
  final Color color;
}
