import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/reader_profile.dart';
import '../controllers/library_controller.dart';

class ProfileSelectionPage extends StatelessWidget {
  final LibraryController controller;

  const ProfileSelectionPage({super.key, required this.controller});

  Future<void> _logout(BuildContext context) async {
    await fb.FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppTheme.obsidian, AppTheme.graphite, Color(0xFF182032)]
                    : [AppTheme.paper, Color(0xFFF4E9D8), Color(0xFFE4F2EC)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const _SelectionBackdrop(),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.ink,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mini Read',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cerrar sesion',
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.logout_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Quien va a leer hoy?',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cada perfil puede tener edad, gustos y una biblioteca recomendada. Maximo ${LibraryController.maxProfiles} por cuenta.',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.66),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = constraints.maxWidth > 560
                              ? (constraints.maxWidth - 18) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: [
                              for (final profile in controller.profiles)
                                SizedBox(
                                  width: cardWidth,
                                  child: _ProfileCard(
                                    profile: profile,
                                    onTap: () async {
                                      await controller.selectProfile(profile);
                                      if (!context.mounted) return;
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
                                    },
                                  ),
                                ),
                              if (controller.canCreateProfile)
                                SizedBox(
                                  width: cardWidth,
                                  child: _AddProfileCard(
                                    enabled: true,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/onboarding',
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ReaderProfile profile;
  final VoidCallback onTap;

  const _ProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Color(profile.accentColor);
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 86,
              height: 104,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: profile.avatarUrl.isEmpty
                        ? Text(
                            profile.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              profile.avatarUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  if (profile.childMode)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.role == 'child' ? 'Nino' : 'Lector'} - ${profile.readingMood}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.62),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final category
                          in profile.favoriteCategories.take(3).toList())
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accent),
          ],
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddProfileCard({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? onTap : null,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: enabled ? 0.72 : 0.42),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black.withValues(alpha: enabled ? 0.08 : 0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: enabled ? AppTheme.moss : Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                enabled ? Icons.add_rounded : Icons.lock_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? 'Crear otro perfil' : 'Limite alcanzado',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    enabled
                        ? 'Edad y gustos en menos de un minuto.'
                        : 'Ya tienes 4 perfiles en esta cuenta.',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
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

class _SelectionBackdrop extends StatelessWidget {
  const _SelectionBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 94,
            right: 22,
            child: Icon(
              Icons.auto_stories_rounded,
              color: AppTheme.coral.withValues(alpha: 0.18),
              size: 88,
            ),
          ),
          Positioned(
            bottom: 84,
            left: 22,
            child: Icon(
              Icons.local_florist_rounded,
              color: AppTheme.moss.withValues(alpha: 0.18),
              size: 78,
            ),
          ),
        ],
      ),
    );
  }
}
