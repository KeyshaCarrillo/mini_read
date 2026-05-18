String formatNumber(num value) {
  final absValue = value.abs();
  final sign = value < 0 ? '-' : '';
  if (absValue >= 1000000) {
    return '$sign${_trim(absValue / 1000000)}M';
  }
  if (absValue >= 1000) {
    return '$sign${_trim(absValue / 1000)}K';
  }
  return value.toInt().toString();
}

String formatDateTime(DateTime? date) {
  if (date == null) return 'Sin fecha';
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = _months[local.month - 1];
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day $month ${local.year}, $hour:$minute';
}

DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _trim(num value) {
  final fixed = value.toStringAsFixed(value >= 10 ? 0 : 1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
