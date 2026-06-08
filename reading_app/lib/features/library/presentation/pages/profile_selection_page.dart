import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/app_theme.dart';
import '../controllers/library_controller.dart';

const Map<String, String> _genreLabels = {
  'fantasia': 'Fantasia',
  'romance': 'Romance',
  'ciencia_ficcion': 'Ciencia ficcion',
  'misterio': 'Misterio',
  'historia': 'Historia',
  'infantil': 'Infantil',
  'terror': 'Terror',
  'aventura': 'Aventura',
};

class ProfileSelectionPage extends StatelessWidget {
  final LibraryController controller;

  const ProfileSelectionPage({super.key, required this.controller});

  Future<void> _logout(BuildContext context) async {
    controller.clearUserState();
    await fb.FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _continueReading(BuildContext context) async {
    final item = controller.readerDashboard.continueReading;
    if (item == null) return;

    if (item.book.pdfUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Este libro aún no tiene PDF disponible.'),
        ),
      );
      return;
    }

    await controller.activateProfileFor(item.profileId);
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/pdf-reader', arguments: item.book);
  }

  void _showUnavailable(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF201A0C),
        content: Text('$label estara disponible muy pronto.'),
      ),
    );
  }

  Future<void> _showMembership(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MembershipSheet(controller: controller),
    );
  }

  Future<void> _showEditProfile(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Scaffold(
            backgroundColor: AppTheme.obsidian,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.obsidian,
          body: Stack(
            children: [
              const Positioned.fill(child: _ProfileBackdrop()),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  children: [
                    _TopBar(onLogout: () => _logout(context)),
                    const SizedBox(height: 18),
                    _ProfileHero(controller: controller),
                    const SizedBox(height: 16),
                    _StatsDashboard(controller: controller),
                    const SizedBox(height: 16),
                    _ContinueReadingCard(
                      controller: controller,
                      onContinue: () => _continueReading(context),
                    ),
                    const SizedBox(height: 16),
                    _LibraryShortcuts(controller: controller),
                    const SizedBox(height: 16),
                    _RecentActivity(controller: controller),
                    const SizedBox(height: 16),
                    _Achievements(controller: controller),
                    const SizedBox(height: 16),
                    _SettingsPanel(
                      onAccount: () => Navigator.pushNamed(context, '/account'),
                      onEditProfile: () => _showEditProfile(context),
                      onChangePhoto: () => _showEditProfile(context),
                      onSwitchProfile: () =>
                          Navigator.pushNamed(context, '/profiles'),
                      onMembership: () => _showMembership(context),
                      onReadingPreferences: () {
                        _showUnavailable(context, 'Preferencias');
                      },
                      onTheme: () => _showUnavailable(context, 'Tema'),
                      onLogout: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onLogout;

  const _TopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.gold, Color(0xFF7B5B19)],
            ),
          ),
          child: const Icon(Icons.menu_book_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Mi cuenta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Cerrar sesion',
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final LibraryController controller;

  const _ProfileHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final name = _resolveAccountName(controller);
    final email = controller.accountEmail.trim();
    final bio = controller.accountBio.trim();
    final genres = controller.accountFavoriteGenres;

    return _GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UserAvatar(name: name, photoUrl: controller.accountPhotoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email.isEmpty ? controller.accountUid : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _PlanBadge(
                isPremium: controller.isPremium,
                membership: controller.accountMembership,
              ),
            ],
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              bio,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (genres.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final genre in genres)
                  _MiniGenreChip(label: _genreLabel(genre)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _resolveAccountName(LibraryController controller) {
    final explicitName = controller.accountName.trim();
    if (explicitName.isNotEmpty) return explicitName;

    final email = controller.accountEmail.trim();
    if (email.contains('@')) return email.split('@').first;

    final uid = controller.accountUid.trim();
    return uid.isEmpty ? email : uid;
  }

  String _genreLabel(String value) {
    return _genreLabels[value] ?? value;
  }
}

class _UserAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;

  const _UserAvatar({required this.name, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final initial = _initialsFor(name);

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0D16A), Color(0xFF9D761F), AppTheme.midnight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: photoUrl.trim().isEmpty
            ? Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Image(
                image: NetworkImage(photoUrl.trim()),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _initialsFor(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _PlanBadge extends StatelessWidget {
  final bool isPremium;
  final String membership;

  const _PlanBadge({required this.isPremium, required this.membership});

  @override
  Widget build(BuildContext context) {
    final normalized = membership.trim().toLowerCase();
    final isPlus = normalized == 'plus';
    final color = isPremium || isPlus ? AppTheme.gold : Colors.white70;
    final label = isPremium
        ? '👑 Premium'
        : isPlus
        ? '⭐ Plus'
        : 'Free';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isPremium || isPlus
            ? AppTheme.gold.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPremium || isPlus
              ? AppTheme.gold.withValues(alpha: 0.34)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium || isPlus
                ? Icons.workspace_premium_rounded
                : Icons.lock_open_rounded,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _MiniGenreChip extends StatelessWidget {
  final String label;

  const _MiniGenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.gold,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  final LibraryController controller;

  const _StatsDashboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dashboard = controller.readerDashboard;
    final minutes = dashboard.totalReadingMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          controller.activeProfile == null
              ? 'Estadísticas del perfil lector'
              : 'Estadísticas de ${controller.activeProfile!.name}',
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.62,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _MetricCard(
              icon: Icons.check_circle_rounded,
              value: '${dashboard.booksRead}',
              label: 'Libros leidos',
            ),
            _MetricCard(
              icon: Icons.auto_stories_rounded,
              value: '${dashboard.booksInProgress}',
              label: 'En progreso',
            ),
            _MetricCard(
              icon: Icons.favorite_rounded,
              value: '${dashboard.favorites}',
              label: 'Favoritos',
            ),
            _MetricCard(
              icon: Icons.local_fire_department_rounded,
              value: '${controller.streakDays}',
              label: 'Racha actual',
            ),
            _MetricCard(
              icon: Icons.schedule_rounded,
              value: _formatMinutes(minutes),
              label: 'Tiempo total',
            ),
            _MetricCard(
              icon: Icons.paid_rounded,
              value: controller.isPremium
                  ? 'IA'
                  : '${controller.totalProfileTokens}',
              label: controller.isPremium ? 'Ilimitada' : 'Monedas',
            ),
          ],
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppTheme.gold, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final LibraryController controller;
  final VoidCallback onContinue;

  const _ContinueReadingCard({
    required this.controller,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final item = controller.readerDashboard.continueReading;

    return _GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Continuar leyendo'),
          const SizedBox(height: 14),
          if (item == null)
            _EmptyState(
              icon: Icons.auto_stories_rounded,
              title: 'Sin lectura reciente',
              body: 'Abre un libro de tu biblioteca para guardar progreso.',
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 70,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Color(item.book.accentColor),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          item.book.accentColor,
                        ).withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProgressBar(progress: item.progress),
                      const SizedBox(height: 7),
                      Text(
                        '${(item.progress * 100).round()}% completado',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continuar'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LibraryShortcuts extends StatelessWidget {
  final LibraryController controller;

  const _LibraryShortcuts({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dashboard = controller.readerDashboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Mi biblioteca'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.35,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _ShortcutCard(
              icon: Icons.favorite_rounded,
              label: 'Favoritos',
              value: '${dashboard.favorites}',
            ),
            _ShortcutCard(
              icon: Icons.bookmark_rounded,
              label: 'Lista de lectura',
              value: '${dashboard.booksInProgress}',
            ),
            _ShortcutCard(
              icon: Icons.verified_rounded,
              label: 'Terminados',
              value: '${dashboard.booksRead}',
            ),
            _ShortcutCard(
              icon: Icons.history_rounded,
              label: 'Historial',
              value: '${dashboard.recentActivity.length}',
            ),
          ],
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final LibraryController controller;

  const _RecentActivity({required this.controller});

  @override
  Widget build(BuildContext context) {
    final recent = controller.readerDashboard.recentActivity;

    return _GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Actividad reciente'),
          const SizedBox(height: 14),
          if (recent.isEmpty)
            _EmptyState(
              icon: Icons.history_rounded,
              title: 'Aun no hay actividad',
              body: 'Tu historial aparecera cuando empieces a leer.',
            )
          else
            for (final activity in recent) ...[
              _ActivityRow(activity: activity),
              if (activity != recent.last)
                Divider(color: Colors.white.withValues(alpha: 0.08)),
            ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final dynamic activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final date = activity.updatedAt is DateTime
        ? _formatDate(activity.updatedAt as DateTime)
        : 'Sin fecha';
    final hasPdf = activity.book.pdfUrl.trim().isNotEmpty;
    final hasPages = activity.book.pages.isNotEmpty;
    final pageTitle = hasPages
        ? activity
              .book
              .pages[(activity.lastPageRead - 1).clamp(
                0,
                activity.book.pages.length - 1,
              )]
              .title
        : hasPdf
        ? 'Documento PDF'
        : 'Pagina ${activity.lastPageRead}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(activity.book.accentColor).withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: Color(activity.book.accentColor),
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$pageTitle - $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(activity.progress * 100).round()}%',
            style: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = today.difference(target).inDays;
    if (days == 0) return 'Hoy';
    if (days == 1) return 'Ayer';
    return 'Hace $days dias';
  }
}

class _Achievements extends StatelessWidget {
  final LibraryController controller;

  const _Achievements({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dashboard = controller.readerDashboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Logros'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Badge(
              icon: Icons.local_fire_department_rounded,
              value: '${controller.bestReadingStreak}',
              label: 'Dias consecutivos leyendo',
            ),
            _Badge(
              icon: Icons.emoji_events_rounded,
              value: '${dashboard.booksRead}',
              label: 'Libros terminados',
            ),
            _Badge(
              icon: Icons.schedule_rounded,
              value: _formatMinutes(dashboard.totalReadingMinutes),
              label: 'Tiempo acumulado',
            ),
          ],
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    return '${hours}h';
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Badge({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: 142,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.gold, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final LibraryController controller;

  const _EditProfileSheet({required this.controller});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _picker = ImagePicker();
  List<String> _selectedGenres = [];
  List<int>? _avatarBytes;
  String _avatarContentType = 'image/jpeg';
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = _initialName();
    _bioController.text = widget.controller.accountBio;
    _selectedGenres = [...widget.controller.accountFavoriteGenres];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 86,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _avatarContentType = picked.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.controller.updateUserProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        favoriteGenres: _selectedGenres,
        avatarBytes: _avatarBytes,
        avatarContentType: _avatarContentType,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Perfil actualizado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _error = e.toString().replaceFirst('Exception:', '').trim(),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + bottomInset),
      child: _GlassPanel(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: _SectionTitle('Editar cuenta')),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: _AvatarEditor(
                    name: _initialName(),
                    photoUrl: widget.controller.accountPhotoUrl,
                    avatarBytes: _avatarBytes,
                    saving: _saving,
                    onCameraPressed: () => _pickImage(ImageSource.camera),
                    onGalleryPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  enabled: !_saving,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    label: 'Nombre de lector',
                    icon: Icons.badge_rounded,
                  ),
                  validator: (value) {
                    return (value ?? '').trim().isEmpty
                        ? 'Escribe tu nombre de lector'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioController,
                  enabled: !_saving,
                  maxLength: 120,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    label: 'Biografia',
                    icon: Icons.auto_stories_rounded,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generos favoritos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _genreLabels.entries)
                      FilterChip(
                        selected: _selectedGenres.contains(entry.key),
                        label: Text(entry.value),
                        onSelected: _saving
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedGenres = [
                                      ..._selectedGenres,
                                      entry.key,
                                    ];
                                  } else {
                                    _selectedGenres = _selectedGenres
                                        .where((genre) => genre != entry.key)
                                        .toList();
                                  }
                                });
                              },
                      ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppTheme.coral,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.gold),
      ),
    );
  }

  String _initialName() {
    final name = widget.controller.accountName.trim();
    if (name.isNotEmpty) return name;

    final email = widget.controller.accountEmail.trim();
    if (email.contains('@')) return email.split('@').first;

    return widget.controller.accountUid.trim();
  }
}

class _AvatarEditor extends StatelessWidget {
  final String name;
  final String photoUrl;
  final List<int>? avatarBytes;
  final bool saving;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _AvatarEditor({
    required this.name,
    required this.photoUrl,
    required this.avatarBytes,
    required this.saving,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EditableAvatarPreview(
          name: name,
          photoUrl: photoUrl,
          avatarBytes: avatarBytes,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: saving ? null : onCameraPressed,
              icon: const Icon(Icons.photo_camera_rounded),
              label: const Text('Camara'),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: saving ? null : onGalleryPressed,
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Galeria'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditableAvatarPreview extends StatefulWidget {
  final String name;
  final String photoUrl;
  final List<int>? avatarBytes;

  const _EditableAvatarPreview({
    required this.name,
    required this.photoUrl,
    required this.avatarBytes,
  });

  @override
  State<_EditableAvatarPreview> createState() => _EditableAvatarPreviewState();
}

class _EditableAvatarPreviewState extends State<_EditableAvatarPreview> {
  ImageProvider? _imageProvider;
  String _lastPhotoUrl = '';
  List<int>? _lastAvatarBytes;

  @override
  void initState() {
    super.initState();
    _syncImageProvider();
  }

  @override
  void didUpdateWidget(covariant _EditableAvatarPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextUrl = widget.photoUrl.trim();
    if (!identical(widget.avatarBytes, _lastAvatarBytes) ||
        nextUrl != _lastPhotoUrl) {
      _syncImageProvider();
    }
  }

  void _syncImageProvider() {
    final bytes = widget.avatarBytes;
    _lastAvatarBytes = bytes;
    _lastPhotoUrl = widget.photoUrl.trim();

    if (bytes != null && bytes.isNotEmpty) {
      _imageProvider = MemoryImage(Uint8List.fromList(bytes));
      return;
    }

    if (_lastPhotoUrl.isNotEmpty) {
      _imageProvider = NetworkImage(_lastPhotoUrl);
      return;
    }

    _imageProvider = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0D16A), Color(0xFF9D761F), AppTheme.midnight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.26),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _imageProvider != null
            ? Image(
                image: _imageProvider!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => _InitialsAvatar(name: widget.name),
              )
            : _InitialsAvatar(name: widget.name),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;

  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initialsFor(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _initialsFor(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _SettingsPanel extends StatelessWidget {
  final VoidCallback onAccount;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePhoto;
  final VoidCallback onSwitchProfile;
  final VoidCallback onMembership;
  final VoidCallback onReadingPreferences;
  final VoidCallback onTheme;
  final VoidCallback onLogout;

  const _SettingsPanel({
    required this.onAccount,
    required this.onEditProfile,
    required this.onChangePhoto,
    required this.onSwitchProfile,
    required this.onMembership,
    required this.onReadingPreferences,
    required this.onTheme,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: _SectionTitle('Configuracion'),
          ),
          _SettingsRow(
            icon: Icons.manage_accounts_rounded,
            label: 'Mi cuenta',
            onTap: onAccount,
          ),
          _SettingsRow(
            icon: Icons.edit_rounded,
            label: 'Editar cuenta',
            onTap: onEditProfile,
          ),
          _SettingsRow(
            icon: Icons.add_a_photo_rounded,
            label: 'Cambiar foto de cuenta',
            onTap: onChangePhoto,
          ),
          _SettingsRow(
            icon: Icons.switch_account_rounded,
            label: 'Cambiar perfil lector',
            onTap: onSwitchProfile,
          ),
          _SettingsRow(
            icon: Icons.workspace_premium_rounded,
            label: 'Planes',
            onTap: onMembership,
          ),
          _SettingsRow(
            icon: Icons.tune_rounded,
            label: 'Preferencias de lectura',
            onTap: onReadingPreferences,
          ),
          _SettingsRow(
            icon: Icons.dark_mode_rounded,
            label: 'Tema',
            onTap: onTheme,
          ),
          _SettingsRow(
            icon: Icons.logout_rounded,
            label: 'Cerrar sesion',
            destructive: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MembershipSheet extends StatelessWidget {
  final LibraryController controller;

  const _MembershipSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: _GlassPanel(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: _SectionTitle('Mi cuenta · Planes')),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'PLAN ACTUAL',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _MembershipPlan(
                name: 'FREE',
                features: [
                  '4 perfiles lectores',
                  'Hasta 2 dispositivos',
                  '20 monedas diarias',
                  'IA básica',
                ],
                active: controller.accountMembership == 'free',
              ),
              const SizedBox(height: 22),
              Text(
                'PRÓXIMAMENTE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _MembershipPlan(
                name: 'PLUS',
                features: [
                  '6 perfiles lectores',
                  'Hasta 3 dispositivos',
                  '50 monedas diarias',
                  'IA avanzada',
                ],
                active: controller.accountMembership == 'plus',
              ),
              const SizedBox(height: 10),
              _MembershipPlan(
                name: 'PREMIUM',
                features: [
                  '8 perfiles lectores',
                  'Hasta 5 dispositivos',
                  '100 monedas diarias',
                  'IA avanzada',
                ],
                active: controller.accountMembership == 'premium',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipPlan extends StatelessWidget {
  final String name;
  final List<String> features;
  final bool active;

  const _MembershipPlan({
    required this.name,
    required this.features,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.gold.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? AppTheme.gold.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: active ? AppTheme.gold : Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Icon(
                    active ? Icons.check_rounded : Icons.circle,
                    color: active ? AppTheme.gold : Colors.white38,
                    size: active ? 18 : 7,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppTheme.coral : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: destructive ? AppTheme.coral : AppTheme.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.34),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GlassPanel({required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF15130F).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: progress.clamp(0.0, 1.0),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF050505), Color(0xFF15110A), Color(0xFF090908)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ProfileLightPainter())),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.24),
                    Colors.black.withValues(alpha: 0.46),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);
    final moss = Paint()
      ..color = AppTheme.moss.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 52);

    final top = Path()
      ..moveTo(size.width * 0.42, -60)
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.02,
        size.width,
        size.height * 0.22,
        size.width * 0.72,
        size.height * 0.3,
      )
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.36,
        size.width * 0.28,
        size.height * 0.06,
        size.width * 0.42,
        -60,
      );
    canvas.drawPath(top, gold);

    final lower = Path()
      ..moveTo(-120, size.height * 0.62)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.48,
        size.width * 0.34,
        size.height * 0.78,
        size.width * 0.1,
        size.height + 80,
      )
      ..lineTo(-120, size.height + 80)
      ..close();
    canvas.drawPath(lower, moss);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
