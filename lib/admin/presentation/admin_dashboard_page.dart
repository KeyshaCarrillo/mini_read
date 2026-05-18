import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../data/admin_api_service.dart';
import '../domain/admin_models.dart';
import 'admin_controller.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key, AdminController? controller})
    : _controller = controller;

  final AdminController? _controller;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminController controller;
  int touchedPieIndex = -1;

  static const background = Color(0xFFFBF8FF);
  static const primary = Color(0xFF000666);
  static const secondary = Color(0xFF775A19);
  static const secondaryContainer = Color(0xFFFED488);

  @override
  void initState() {
    super.initState();
    controller = widget._controller ??
        AdminController(
          api: AdminApiService(
            client: http.Client(),
            auth: fb.FirebaseAuth.instance,
          ),
        );
    controller.addListener(_onControllerChanged);
    controller.refresh();
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = controller.isDarkMode ? _darkTheme() : _lightTheme();
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: controller.isDarkMode ? const Color(0xFF080A20) : background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final content = _MainContent(
              controller: controller,
              compact: compact,
              touchedPieIndex: touchedPieIndex,
              onPieTouched: (index) => setState(() => touchedPieIndex = index),
              onAddBook: _showCreateBookDialog,
              onTransactionTap: _showTransactionDetail,
            );
            if (compact) {
              return Column(
                children: [
                  _TopBar(controller: controller, compact: compact),
                  Expanded(child: content),
                ],
              );
            }
            return Row(
              children: [
                _Sidebar(controller: controller),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(controller: controller, compact: compact),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondaryContainer,
        brightness: Brightness.dark,
        primary: secondaryContainer,
        secondary: secondaryContainer,
        surface: const Color(0xFF101330),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF080A20),
      cardTheme: CardThemeData(
        color: const Color(0xFF101330),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Future<void> _showCreateBookDialog() async {
    final id = TextEditingController();
    final title = TextEditingController();
    final category = TextEditingController(text: 'Niños');
    final pages = TextEditingController(text: '5');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir libro desde Firebase/API'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: id,
                  decoration: const InputDecoration(labelText: 'ID opcional'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El titulo es obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pages,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Numero de paginas'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    return parsed == null || parsed < 1
                        ? 'Escribe un numero mayor a cero'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await controller.createBook(
                id: id.text,
                title: title.text,
                category: category.text,
                pagesCount: int.parse(pages.text),
              );
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(TokenTransaction transaction) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaccion ${transaction.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Usuario', transaction.uid),
            _detail('Perfil', transaction.profileId.isEmpty ? 'N/A' : transaction.profileId),
            _detail('Tipo', transaction.type),
            _detail('Recompensa', transaction.reward.isEmpty ? 'Movimiento de tokens' : transaction.reward),
            _detail('Cantidad', '${transaction.amount} tokens'),
            _detail('Fecha', _formatDate(transaction.createdAt)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text('$label: $value'),
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.controller});

  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: _AdminDashboardPageState.primary,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories, color: Colors.white, size: 30),
              SizedBox(width: 12),
              Text(
                'Mini Read Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          _NavItem(controller: controller, section: AdminSection.dashboard, icon: Icons.dashboard_rounded, label: 'Dashboard General'),
          _NavItem(controller: controller, section: AdminSection.users, icon: Icons.group_rounded, label: 'Gestión de Usuarios'),
          _NavItem(controller: controller, section: AdminSection.tokens, icon: Icons.toll_rounded, label: 'Historial de Tokens'),
          _NavItem(controller: controller, section: AdminSection.settings, icon: Icons.settings_rounded, label: 'Configuración'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AdminDashboardPageState.secondaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Panel conectado a Firebase mediante la API real.',
              style: TextStyle(
                color: _AdminDashboardPageState.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.controller,
    required this.section,
    required this.icon,
    required this.label,
  });

  final AdminController controller;
  final AdminSection section;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selected = controller.section == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.selectSection(section),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withValues(alpha: .16) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? _AdminDashboardPageState.secondaryContainer : Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller, required this.compact});

  final AdminController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 18, compact ? 16 : 28, 12),
      child: Row(
        children: [
          if (compact)
            PopupMenuButton<AdminSection>(
              icon: const Icon(Icons.menu_rounded),
              onSelected: controller.selectSection,
              itemBuilder: (context) => const [
                PopupMenuItem(value: AdminSection.dashboard, child: Text('Dashboard General')),
                PopupMenuItem(value: AdminSection.users, child: Text('Gestión de Usuarios')),
                PopupMenuItem(value: AdminSection.tokens, child: Text('Historial de Tokens')),
                PopupMenuItem(value: AdminSection.settings, child: Text('Configuración')),
              ],
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(controller.section),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  'Datos en vivo desde Firebase: libros, usuarios, tokens e IA.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Recargar datos',
            onPressed: controller.isLoading ? null : controller.refresh,
            icon: controller.isLoading
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.dark_mode_outlined),
          Switch(value: controller.isDarkMode, onChanged: controller.setDarkMode),
        ],
      ),
    );
  }

  String _title(AdminSection section) => switch (section) {
    AdminSection.dashboard => 'Dashboard General',
    AdminSection.users => 'Gestión de Usuarios y Libros',
    AdminSection.tokens => 'Historial de Tokens',
    AdminSection.settings => 'Configuración',
  };
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.controller,
    required this.compact,
    required this.touchedPieIndex,
    required this.onPieTouched,
    required this.onAddBook,
    required this.onTransactionTap,
  });

  final AdminController controller;
  final bool compact;
  final int touchedPieIndex;
  final ValueChanged<int> onPieTouched;
  final VoidCallback onAddBook;
  final ValueChanged<TokenTransaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 12, compact ? 16 : 28, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.error != null) _ErrorBanner(message: controller.error!),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: switch (controller.section) {
                  AdminSection.dashboard => _DashboardView(
                    controller: controller,
                    compact: compact,
                    touchedPieIndex: touchedPieIndex,
                    onPieTouched: onPieTouched,
                  ),
                  AdminSection.users => _UsersBooksView(controller: controller, compact: compact, onAddBook: onAddBook),
                  AdminSection.tokens => _TokensView(controller: controller, onTransactionTap: onTransactionTap),
                  AdminSection.settings => _SettingsView(controller: controller),
                },
              ),
            ],
          ),
        ),
        if (controller.section == AdminSection.users)
          Positioned(
            right: compact ? 18 : 34,
            bottom: 22,
            child: FloatingActionButton.extended(
              onPressed: onAddBook,
              backgroundColor: _AdminDashboardPageState.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Añadir Libro'),
            ),
          ),
      ],
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.controller,
    required this.compact,
    required this.touchedPieIndex,
    required this.onPieTouched,
  });

  final AdminController controller;
  final bool compact;
  final int touchedPieIndex;
  final ValueChanged<int> onPieTouched;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('dashboard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(title: 'Libros activos', value: '${controller.totalBooks}', icon: Icons.menu_book_rounded, warning: controller.hasInventoryWarning ? 'Faltan libros para el inventario ideal.' : null),
            _StatCard(title: 'Usuarios', value: '${controller.totalUsers}', icon: Icons.people_alt_rounded),
            _StatCard(title: 'Premium', value: '${controller.premiumUsers}', icon: Icons.workspace_premium_rounded, gold: true),
            _StatCard(title: 'Balance tokens', value: '${controller.tokenBalance}', icon: Icons.paid_rounded),
          ],
        ),
        const SizedBox(height: 22),
        Flex(
          direction: compact ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandedOrFull(compact: compact, child: _BarChartCard(controller: controller)),
            SizedBox(width: compact ? 0 : 18, height: compact ? 18 : 0),
            ExpandedOrFull(compact: compact, child: _PieChartCard(touchedPieIndex: touchedPieIndex, onPieTouched: onPieTouched)),
          ],
        ),
        const SizedBox(height: 22),
        _BooksInventory(controller: controller),
      ],
    );
  }
}

class ExpandedOrFull extends StatelessWidget {
  const ExpandedOrFull({super.key, required this.compact, required this.child});
  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) => compact ? child : Expanded(child: child);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, this.warning, this.gold = false});
  final String title;
  final String value;
  final IconData icon;
  final String? warning;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: gold ? _AdminDashboardPageState.secondaryContainer : _AdminDashboardPageState.primary.withValues(alpha: .10),
                foregroundColor: gold ? _AdminDashboardPageState.secondary : _AdminDashboardPageState.primary,
                child: Icon(icon),
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              if (warning != null) ...[
                const SizedBox(height: 8),
                Text(warning!, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    final usage = controller.monthlyUsage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consumo mensual de tokens', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (var i = 0; i < usage.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: usage[i].ads.toDouble(), color: _AdminDashboardPageState.secondaryContainer, width: 12),
                          BarChartRodData(toY: usage[i].ai.toDouble(), color: _AdminDashboardPageState.primary, width: 12),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= usage.length) return const SizedBox.shrink();
                          return Text(usage[index].label);
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const Wrap(
              spacing: 16,
              children: [
                _Legend(color: _AdminDashboardPageState.secondaryContainer, label: 'Anuncios'),
                _Legend(color: _AdminDashboardPageState.primary, label: 'Consultas IA'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({required this.touchedPieIndex, required this.onPieTouched});
  final int touchedPieIndex;
  final ValueChanged<int> onPieTouched;

  @override
  Widget build(BuildContext context) {
    const values = [60.0, 25.0, 15.0];
    const labels = ['Niños', 'Adolescentes', 'Adultos'];
    const colors = [Color(0xFF000666), Color(0xFFFED488), Color(0xFF775A19)];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Segmentación por edades', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    for (var i = 0; i < values.length; i++)
                      PieChartSectionData(
                        value: values[i],
                        title: '${values[i].toInt()}%',
                        radius: touchedPieIndex == i ? 106 : 88,
                        color: colors[i],
                        titleStyle: TextStyle(
                          color: i == 1 ? _AdminDashboardPageState.secondary : Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 42,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      onPieTouched(response?.touchedSection?.touchedSectionIndex ?? -1);
                    },
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 14,
              children: [
                for (var i = 0; i < labels.length; i++) _Legend(color: colors[i], label: labels[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}

class _UsersBooksView extends StatelessWidget {
  const _UsersBooksView({required this.controller, required this.compact, required this.onAddBook});
  final AdminController controller;
  final bool compact;
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('users'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Control de usuarios', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                    FilledButton.icon(onPressed: onAddBook, icon: const Icon(Icons.add), label: const Text('Añadir Libro')),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 430,
                  child: DataTable2(
                    columnSpacing: 14,
                    minWidth: 760,
                    columns: const [
                      DataColumn2(label: Text('Usuario'), size: ColumnSize.L),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Plan')),
                      DataColumn(label: Text('Tokens')),
                      DataColumn2(label: Text('Acciones'), size: ColumnSize.L),
                    ],
                    rows: controller.users.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.name)),
                        DataCell(Text(user.email)),
                        DataCell(Chip(label: Text(user.isPremium ? 'Premium' : 'Gratis'))),
                        DataCell(Text('${user.tokens}')),
                        DataCell(Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(onPressed: user.isPremium ? null : () => controller.makePremium(user), child: const Text('Hacer Premium')),
                            FilledButton.tonal(onPressed: () => controller.toggleBan(user), child: Text(user.isBanned ? 'Reactivar' : 'Banear')),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        _BooksInventory(controller: controller),
      ],
    );
  }
}

class _BooksInventory extends StatelessWidget {
  const _BooksInventory({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventario de libros', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: controller.books.map((book) => SizedBox(
                width: 250,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _AdminDashboardPageState.primary.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _AdminDashboardPageState.primary.withValues(alpha: .10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('${book.category} • ${book.pagesCount} páginas'),
                      Text(book.author, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showEditBookDialog(context, controller, book),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Editar'),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Eliminar libro',
                            onPressed: () => _confirmDelete(context, controller, book),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
            if (controller.books.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Todavía no hay libros cargados desde /api/books.'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditBookDialog(
    BuildContext context,
    AdminController controller,
    AdminBook book,
  ) async {
    final title = TextEditingController(text: book.title);
    final category = TextEditingController(text: book.category);
    final pages = TextEditingController(text: '${book.pagesCount == 0 ? 1 : book.pagesCount}');
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${book.title}'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El titulo es obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pages,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Paginas'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    return parsed == null || parsed < 1
                        ? 'Escribe un numero mayor a cero'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await controller.updateBook(
                book: book,
                title: title.text,
                category: category.text,
                pagesCount: int.parse(pages.text),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminController controller,
    AdminBook book,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Quieres eliminar "${book.title}" de Firebase?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteBook(book);
  }
}

class _TokensView extends StatelessWidget {
  const _TokensView({required this.controller, required this.onTransactionTap});
  final AdminController controller;
  final ValueChanged<TokenTransaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('tokens'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actividad reciente de tokens', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            SizedBox(
              height: 560,
              child: DataTable2(
                columnSpacing: 14,
                minWidth: 820,
                columns: const [
                  DataColumn2(label: Text('ID'), size: ColumnSize.L),
                  DataColumn(label: Text('Usuario')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Tokens')),
                  DataColumn(label: Text('Fecha')),
                ],
                rows: controller.transactions.map((tx) => DataRow(
                  onSelectChanged: (_) => onTransactionTap(tx),
                  cells: [
                    DataCell(Text(tx.id)),
                    DataCell(Text(tx.uid)),
                    DataCell(Text(tx.type)),
                    DataCell(Text('${tx.amount}')),
                    DataCell(Text(_formatDate(tx.createdAt))),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('settings'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('BaseURL activa: https://book-api-nu-six.vercel.app/api'),
            const SizedBox(height: 8),
            const Text('Los endpoints administrativos usan el ID token de Firebase Auth y requieren rol administrador en el backend.'),
            const SizedBox(height: 24),
            Text('Consultas recientes a IA', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            for (final chat in controller.aiChats.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.smart_toy_outlined),
                title: Text(chat.question.isEmpty ? 'Pregunta sin texto' : chat.question),
                subtitle: Text(chat.answer.isEmpty ? chat.uid : chat.answer, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(_formatDate(chat.createdAt)),
              ),
            if (controller.aiChats.isEmpty)
              const Text('Sin consultas de IA cargadas desde /api/admin/ia_chats.'),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Sin fecha';
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}
