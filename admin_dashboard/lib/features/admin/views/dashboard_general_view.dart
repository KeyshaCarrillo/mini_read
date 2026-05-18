import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_cards.dart';
import '../widgets/admin_design_tokens.dart';

class DashboardGeneralView extends StatelessWidget {
  const DashboardGeneralView({super.key, required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.errorMessage != null) _ApiWarning(message: controller.errorMessage!, onRetry: controller.refresh),
          if (controller.hasBookAlert)
            const _BookAlert(),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1180 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.55,
                children: [
                  StatCard(label: 'Libros publicados', value: '${controller.books.length}', icon: Icons.menu_book_rounded, accent: StitchAdminColors.deepBlue, caption: 'Dato leído desde /api/books', warning: controller.hasBookAlert),
                  StatCard(label: 'Usuarios activos', value: '${controller.activeUsers}', icon: Icons.group_rounded, accent: const Color(0xFF2563EB), caption: '${controller.premiumUsers} usuarios premium'),
                  StatCard(label: 'Tokens procesados', value: '${controller.totalTokens}', icon: Icons.generating_tokens_rounded, accent: StitchAdminColors.gold, caption: 'Anuncios + consultas IA'),
                  StatCard(label: 'Transacciones', value: '${controller.tokenTransactions.length}', icon: Icons.receipt_long_rounded, accent: const Color(0xFF059669), caption: 'Actividad cronológica'),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1050;
              final bar = _TokenBarChart(controller: controller);
              const pie = _AgeSegmentationChart();
              return compact
                  ? Column(children: [bar, const SizedBox(height: 18), pie])
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 7, child: bar), const SizedBox(width: 18), const Expanded(flex: 4, child: pie)]);
            },
          ),
        ],
      ),
    );
  }
}

class _ApiWarning extends StatelessWidget {
  const _ApiWarning({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AdminPanel(
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Color(0xFFB45309)),
            const SizedBox(width: 12),
            Expanded(child: Text('No se pudieron cargar datos del API real: $message')),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _BookAlert extends StatelessWidget {
  const _BookAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: StitchAdminColors.goldContainer, borderRadius: BorderRadius.circular(18)),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: StitchAdminColors.gold),
          SizedBox(width: 12),
          Expanded(child: Text('Alerta editorial: faltan libros para alcanzar el inventario mínimo recomendado.', style: TextStyle(color: StitchAdminColors.gold, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _TokenBarChart extends StatelessWidget {
  const _TokenBarChart({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.monthlyTokenUsage;
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Consumo mensual de tokens', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Comparativa de anuncios vs consultas de IA procesada desde /api/admin/token_transactions.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          SizedBox(
            height: 320,
            child: BarChart(
              BarChartData(
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(x: i, barsSpace: 5, barRods: [
                      BarChartRodData(toY: data[i].adsTokens, color: StitchAdminColors.goldContainer, width: 13, borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(toY: data[i].aiTokens, color: StitchAdminColors.deepBlue, width: 13, borderRadius: BorderRadius.circular(4)),
                    ]),
                ],
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Theme.of(context).dividerColor)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 8), child: Text(data[index].monthLabel));
                  })),
                ),
                barTouchData: BarTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeSegmentationChart extends StatefulWidget {
  const _AgeSegmentationChart();

  @override
  State<_AgeSegmentationChart> createState() => _AgeSegmentationChartState();
}

class _AgeSegmentationChartState extends State<_AgeSegmentationChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final segments = [
      ('Niños', 60.0, StitchAdminColors.deepBlue),
      ('Adolescentes', 25.0, StitchAdminColors.goldContainer),
      ('Adultos', 15.0, const Color(0xFF7C3AED)),
    ];
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Segmentación por edades', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Hover para resaltar cada segmento.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 22),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 52,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(touchCallback: (_, response) {
                  setState(() => touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1);
                }),
                sections: [
                  for (var i = 0; i < segments.length; i++)
                    PieChartSectionData(
                      value: segments[i].$2,
                      color: segments[i].$3,
                      radius: touchedIndex == i ? 42 : 32,
                      title: touchedIndex == i ? '${segments[i].$2.toStringAsFixed(0)}%' : '',
                      titleStyle: TextStyle(color: i == 1 ? StitchAdminColors.gold : Colors.white, fontWeight: FontWeight.w900),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...segments.map((segment) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 9, height: 9, decoration: BoxDecoration(color: segment.$3, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(segment.$1, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text('${segment.$2.toStringAsFixed(0)}%'),
                ]),
              )),
        ],
      ),
    );
  }
}
