import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/token_transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final metrics = admin.metrics;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1280
        ? 4
        : width > 760
        ? 2
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: width > 760 ? 2.1 : 2.4,
          children: [
            StatCard(
              title: 'Total Usuarios',
              value: formatNumber(metrics.totalUsers),
              trend: '+ datos API',
              icon: Icons.group_rounded,
              iconColor: AppColors.primary,
            ),
            StatCard(
              title: 'Usuarios Premium',
              value: formatNumber(metrics.premiumUsers),
              trend:
                  '${metrics.totalUsers == 0 ? 0 : ((metrics.premiumUsers / metrics.totalUsers) * 100).round()}% conversión',
              icon: Icons.star_rounded,
              iconColor: AppColors.secondary,
            ),
            StatCard(
              title: 'Tokens en Circulación',
              value: formatNumber(metrics.tokensInCirculation),
              trend: 'Economía activa',
              icon: Icons.toll_rounded,
              iconColor: AppColors.primary,
            ),
            StatCard(
              title: 'Libros en la API',
              value: '${metrics.totalBooks}',
              trend: metrics.totalBooks == 0
                  ? 'Inventario pendiente'
                  : 'Inventario conectado',
              icon: Icons.menu_book_rounded,
              iconColor: metrics.totalBooks == 0
                  ? AppColors.error
                  : AppColors.primary,
              warning: metrics.totalBooks == 0,
            ),
          ],
        ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1000;
            final charts = [
              _ChartPanel(
                title: 'Consumo de Tokens',
                subtitle: 'Comparativa mensual de flujos',
                showLegend: true,
                child: SizedBox(
                  height: 320,
                  child: TokenBarChart(transactions: admin.transactions),
                ),
              ),
              _ChartPanel(
                title: 'Distribución por Edades',
                subtitle: 'Segmentación de la base de usuarios',
                child: SizedBox(
                  height: 320,
                  child: AgePieChart(totalUsers: metrics.totalUsers),
                ),
              ),
            ];

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  charts.first,
                  const SizedBox(height: 24),
                  charts.last,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: charts.first),
                const SizedBox(width: 24),
                Expanded(child: charts.last),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _ChartPanel(
          title: 'Tendencia Semanal',
          subtitle: 'Movimiento neto de tokens en los últimos días',
          child: SizedBox(
            height: 260,
            child: TokenLineChart(transactions: admin.transactions),
          ),
        ),
        const SizedBox(height: 24),
        _RecentActivity(transactions: admin.transactions.take(5).toList()),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color iconColor;
  final bool warning;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(icon, color: iconColor),
              ],
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                Icon(
                  warning
                      ? Icons.report_problem_rounded
                      : Icons.trending_up_rounded,
                  size: 16,
                  color: warning ? AppColors.error : AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trend,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: warning ? AppColors.error : AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showLegend;

  const _ChartPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.showLegend = false,
  });

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showLegend) ...[
                  const _Legend(color: AppColors.primary, label: 'Anuncios'),
                  const SizedBox(width: 16),
                  const _Legend(
                    color: AppColors.secondaryContainer,
                    label: 'IA',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class TokenBarChart extends StatelessWidget {
  final List<TokenTransaction> transactions;

  const TokenBarChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final values = _monthlyValues(transactions);
    final maxY = values.fold<double>(
      20,
      (max, item) => math.max(max, math.max(item.reward, item.ai)),
    );

    return BarChart(
      BarChartData(
        maxY: maxY * 1.25,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                formatNumber(value),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= values.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(values[index].month),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: values[i].reward,
                  color: AppColors.primary,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
                BarChartRodData(
                  toY: values[i].ai,
                  color: AppColors.secondaryContainer,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AgePieChart extends StatefulWidget {
  final int totalUsers;

  const AgePieChart({super.key, required this.totalUsers});

  @override
  State<AgePieChart> createState() => _AgePieChartState();
}

class _AgePieChartState extends State<AgePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.totalUsers == 0
        ? '0'
        : formatNumber(widget.totalUsers);
    final sections = [
      _PieEntry('Ninos (6-12)', 60, AppColors.primary),
      _PieEntry('Adolescentes', 25, AppColors.secondaryContainer),
      _PieEntry('Adultos', 15, AppColors.outline),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 66,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    touchedIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: [
                for (var i = 0; i < sections.length; i++)
                  PieChartSectionData(
                    value: sections[i].value,
                    title: '${sections[i].value.round()}%',
                    radius: touchedIndex == i ? 84 : 74,
                    color: sections[i].color,
                    titleStyle: TextStyle(
                      color: i == 1 ? AppColors.onSurface : Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Text(
          '$total Usuarios',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        for (final entry in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: entry.color),
                const SizedBox(width: 8),
                Expanded(child: Text(entry.label)),
                Text('${entry.value.round()}%'),
              ],
            ),
          ),
      ],
    );
  }
}

class TokenLineChart extends StatelessWidget {
  final List<TokenTransaction> transactions;

  const TokenLineChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final points = _dailyNet(transactions);
    final maxAbs = points.fold<double>(
      20,
      (max, point) => math.max(max, point.value.abs()),
    );

    return LineChart(
      LineChartData(
        minY: -maxAbs * 1.2,
        maxY: maxAbs * 1.2,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                formatNumber(value),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(points[index].label),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<TokenTransaction> transactions;

  const _RecentActivity({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  'Actividad Reciente de Usuarios',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.read<AdminController>().setSection(
                    AdminSection.tokens,
                  ),
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('Ver todo'),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Usuario')),
                DataColumn(label: Text('Acción')),
                DataColumn(label: Text('Monto/Token')),
                DataColumn(label: Text('Fecha')),
              ],
              rows: [
                for (final transaction in transactions)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          transaction.uid.isEmpty
                              ? 'Usuario'
                              : transaction.uid.substring(
                                  0,
                                  math.min(8, transaction.uid.length),
                                ),
                        ),
                      ),
                      DataCell(_ChipLabel(transaction: transaction)),
                      DataCell(
                        Text(
                          '${transaction.amount > 0 ? '+' : ''}${transaction.amount}',
                        ),
                      ),
                      DataCell(Text(formatDateTime(transaction.createdAt))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final TokenTransaction transaction;

  const _ChipLabel({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(transaction.label),
      backgroundColor: transaction.isReward
          ? AppColors.secondaryContainer.withValues(alpha: 0.35)
          : AppColors.primaryContainer.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: transaction.isReward ? AppColors.secondary : AppColors.primary,
      ),
    );
  }
}

class _MonthValue {
  final String month;
  final double reward;
  final double ai;

  const _MonthValue(this.month, this.reward, this.ai);
}

class _DailyValue {
  final String label;
  final double value;

  const _DailyValue(this.label, this.value);
}

class _PieEntry {
  final String label;
  final double value;
  final Color color;

  const _PieEntry(this.label, this.value, this.color);
}

List<_MonthValue> _monthlyValues(List<TokenTransaction> transactions) {
  const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
  final now = DateTime.now();
  final months = List.generate(6, (index) {
    return DateTime(now.year, now.month - 5 + index);
  });

  return [
    for (var i = 0; i < months.length; i++)
      _MonthValue(
        labels[(months[i].month - 1) % labels.length],
        transactions
            .where(
              (item) =>
                  item.createdAt?.month == months[i].month &&
                  item.createdAt?.year == months[i].year &&
                  item.amount > 0,
            )
            .fold<double>(0, (total, item) => total + item.amount),
        transactions
            .where(
              (item) =>
                  item.createdAt?.month == months[i].month &&
                  item.createdAt?.year == months[i].year &&
                  (item.amount < 0 || item.type.contains('ai')),
            )
            .fold<double>(0, (total, item) => total + item.amount.abs()),
      ),
  ];
}

List<_DailyValue> _dailyNet(List<TokenTransaction> transactions) {
  final now = DateTime.now();
  final days = List.generate(7, (index) {
    return DateTime(now.year, now.month, now.day - 6 + index);
  });

  return [
    for (final day in days)
      _DailyValue(
        '${day.day}/${day.month}',
        transactions
            .where(
              (item) =>
                  item.createdAt?.year == day.year &&
                  item.createdAt?.month == day.month &&
                  item.createdAt?.day == day.day,
            )
            .fold<double>(0, (total, item) => total + item.amount),
      ),
  ];
}
