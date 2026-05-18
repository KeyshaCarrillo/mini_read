import 'package:flutter/material.dart';

import '../../../domain/entities/reader_profile.dart';
import '../../../../../shared/widgets/status_badge.dart';

class LibraryTopbar extends StatelessWidget {
  final ReaderProfile? profile;
  final bool isPremium;
  final bool actionLoading;
  final VoidCallback onProfiles;
  final VoidCallback onReward;

  const LibraryTopbar({
    super.key,
    required this.profile,
    required this.isPremium,
    required this.actionLoading,
    required this.onProfiles,
    required this.onReward,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.86),
        border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.65))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Buscar libros, autores, perfiles o acciones...',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('⌘ K', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          StatusBadge(
            label: actionLoading ? 'Sincronizando' : 'Live',
            color: actionLoading ? const Color(0xFFD97706) : const Color(0xFF059669),
            icon: actionLoading ? Icons.sync_rounded : Icons.check_circle_rounded,
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            tooltip: 'Acción rápida: ver anuncio',
            onPressed: actionLoading ? null : onReward,
            icon: actionLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.bolt_rounded),
          ),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Cambiar tema',
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onProfiles,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(profile?.accentColor ?? 0xFF4F46E5),
                  child: Text(
                    (profile?.name.isNotEmpty ?? false) ? profile!.name[0].toUpperCase() : 'M',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name ?? 'Sin perfil',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        isPremium ? 'Plan Premium' : 'Plan Gratis',
                        style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
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
