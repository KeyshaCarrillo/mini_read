import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/hoverable_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../controllers/library_controller.dart';
import '../layouts/enterprise_library_shell.dart';
import '../widgets/dashboard/book_table.dart';
import '../widgets/dashboard/kpi_card.dart';
import '../widgets/dashboard/library_chart_card.dart';

class LibraryHomePage extends StatelessWidget {
  final LibraryController controller;

  const LibraryHomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return EnterpriseLibraryShell(
          controller: controller,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            child: controller.loading
                ? const _DashboardSkeleton(key: ValueKey('loading'))
                : _DashboardContent(
                    key: const ValueKey('dashboard'),
                    controller: controller,
                  ),
          ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final LibraryController controller;

  const _DashboardContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.activeProfile;
    final recommended = controller.recommendedBooks;
    final childBooks = controller.childBooks;
    final generalBooks = controller.generalBooks;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.pagePadding(width);
        final kpiColumns = AppBreakpoints.kpiColumns(width);
        final contentMaxWidth = AppBreakpoints.isWide(width) ? 1360.0 : double.infinity;

        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHeader(
                      profileName: profile?.name ?? 'Biblioteca',
                      subtitle: profile?.readingMood ?? 'Administra catálogo, perfiles y acceso AI desde una vista productiva.',
                      categories: profile?.favoriteCategories ?? const [],
                    ),
                    const SizedBox(height: 22),
                    _KpiGrid(
                      columns: kpiColumns,
                      children: [
                        KpiCard(
                          label: 'Libros disponibles',
                          value: '${controller.books.length}',
                          trend: '${recommended.length} recomendados activos',
                          icon: Icons.auto_stories_rounded,
                          color: AppTheme.indigo600,
                        ),
                        KpiCard(
                          label: 'Monedas AI',
                          value: '${controller.coins}',
                          trend: controller.isPremium ? 'Premium desbloqueado' : '+30 por anuncio disponible',
                          icon: Icons.toll_rounded,
                          color: const Color(0xFF0F766E),
                        ),
                        KpiCard(
                          label: 'Racha lectora',
                          value: '${controller.streakDays}d',
                          trend: 'Check-in diario sincronizado',
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFD97706),
                        ),
                        KpiCard(
                          label: 'Perfiles',
                          value: '${controller.profiles.length}/${LibraryController.maxProfiles}',
                          trend: controller.canCreateProfile ? 'Capacidad disponible' : 'Límite alcanzado',
                          icon: Icons.group_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ResponsivePanels(
                      left: LibraryChartCard(books: controller.books),
                      right: _OperationsPanel(controller: controller),
                    ),
                    const SizedBox(height: 22),
                    if (controller.books.isEmpty)
                      const _EmptyStatePanel()
                    else ...[
                      _RecommendedRail(
                        title: 'Recomendado para el perfil',
                        books: recommended,
                        onOpen: (book) => Navigator.pushNamed(context, '/book', arguments: book),
                      ),
                      const SizedBox(height: 22),
                      BookTable(
                        books: [...childBooks, ...generalBooks],
                        onOpen: (book) => Navigator.pushNamed(context, '/book', arguments: book),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String profileName;
  final String subtitle;
  final List<String> categories;

  const _DashboardHeader({
    required this.profileName,
    required this.subtitle,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Dashboard', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.chevron_right_rounded, size: 16),
                  ),
                  Text(profileName, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Library Operations',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.4,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  subtitle,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, height: 1.45, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (categories.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: categories.take(3).map((category) => StatusBadge(label: category, color: AppTheme.indigo600)).toList(),
          ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final int columns;
  final List<Widget> children;

  const _KpiGrid({required this.columns, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.0;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
        );
      },
    );
  }
}

class _ResponsivePanels extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ResponsivePanels({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.laptop) {
          return Column(children: [left, const SizedBox(height: 16), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: left),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: right),
          ],
        );
      },
    );
  }
}

class _OperationsPanel extends StatelessWidget {
  final LibraryController controller;

  const _OperationsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = controller.activeProfile;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado del sistema', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Visibilidad inmediata de sincronización, plan y perfil activo.', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            _SystemRow(icon: Icons.cloud_done_rounded, label: 'Backend', value: controller.actionLoading ? 'Sincronizando' : 'Operativo'),
            _SystemRow(icon: Icons.person_pin_rounded, label: 'Perfil activo', value: profile?.name ?? 'Pendiente'),
            _SystemRow(icon: Icons.workspace_premium_rounded, label: 'Plan', value: controller.isPremium ? 'Premium' : 'Gratis'),
            _SystemRow(icon: Icons.auto_awesome_motion_rounded, label: 'Lecturas visuales', value: '${controller.books.where((book) => book.hasImmersiveImages).length}'),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.actionLoading ? null : controller.rewardAdWatched,
                    icon: controller.actionLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_circle_rounded),
                    label: const Text('Añadir +30'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/profiles'),
                  icon: const Icon(Icons.switch_account_rounded),
                  label: const Text('Perfil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SystemRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _RecommendedRail extends StatelessWidget {
  final String title;
  final List<Book> books;
  final ValueChanged<Book> onOpen;

  const _RecommendedRail({required this.title, required this.books, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5))),
            Text('${books.length} items', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.take(8).length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) => SizedBox(
              width: 300,
              child: _BookCard(book: books[index], onTap: () => onOpen(books[index])),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = Color(book.accentColor);
    return HoverableCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                child: Icon(book.hasImmersiveImages ? Icons.image_rounded : Icons.auto_stories_rounded, color: accent),
              ),
              const Spacer(),
              StatusBadge(label: book.audience, color: accent),
            ],
          ),
          const SizedBox(height: 16),
          Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.15)),
          const SizedBox(height: 8),
          Text(book.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.35, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${book.category} · ${book.estimatedMinutes} min', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmptyStatePanel extends StatelessWidget {
  const _EmptyStatePanel();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.dataset_linked_rounded, color: scheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catálogo conectado, sin documentos todavía', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    'El dashboard conserva la lógica funcional original: cuando Firestore o la API no retornan libros, se muestra un estado vacío claro con siguiente acción contextual.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = AppBreakpoints.pagePadding(constraints.maxWidth);
        return SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(width: 220, height: 20),
              const SizedBox(height: 14),
              const SkeletonLoader(width: 420, height: 44),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(4, (_) => const SkeletonLoader(width: 260, height: 168)),
              ),
              const SizedBox(height: 22),
              const SkeletonLoader(width: double.infinity, height: 330),
            ],
          ),
        );
      },
    );
  }
}
