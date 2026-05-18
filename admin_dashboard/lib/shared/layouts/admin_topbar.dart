import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_spacing.dart';
import '../extensions/context_extensions.dart';

class AdminTopbar extends StatelessWidget {
  const AdminTopbar({super.key, required this.isDark, required this.onThemeToggle});

  final bool isDark;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF09090B) : Colors.white,
        border: Border(bottom: BorderSide(color: context.theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text('Admin', style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
          Icon(Icons.chevron_right_rounded, size: 18, color: context.colors.onSurfaceVariant),
          Text('Dashboard overview', style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          const _GlobalSearch(),
          const SizedBox(width: AppSpacing.md),
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Quick action')),
          const SizedBox(width: AppSpacing.xs),
          IconButton(onPressed: onThemeToggle, tooltip: 'Toggle theme', icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
          IconButton(onPressed: () {}, tooltip: 'Notifications', icon: Badge.count(count: 4, child: const Icon(Icons.notifications_none_rounded))),
          const SizedBox(width: AppSpacing.xs),
          const _AdminProfile(),
        ],
      ),
    );
  }
}

class _GlobalSearch extends StatelessWidget {
  const _GlobalSearch();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, minWidth: 260),
      child: TextField(
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search users, reports, tokens...',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(border: Border.all(color: context.theme.dividerColor), borderRadius: BorderRadius.circular(6)),
            child: Text('⌘K', style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
          ),
          filled: true,
          fillColor: context.isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.theme.dividerColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.theme.dividerColor)),
        ),
      ),
    );
  }
}

class _AdminProfile extends StatelessWidget {
  const _AdminProfile();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Admin profile',
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'audit', child: Text('Audit log')),
        PopupMenuItem(value: 'logout', child: Text('Sign out')),
      ],
      child: Row(
        children: [
          CircleAvatar(radius: 17, backgroundColor: context.colors.primary.withValues(alpha: .12), child: Text('AD', style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w800, fontSize: 12))),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Ops', style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text(AppConfig.environment, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
