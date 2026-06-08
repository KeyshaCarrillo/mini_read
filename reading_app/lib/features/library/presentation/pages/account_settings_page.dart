import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/services/account_service.dart';
import '../controllers/library_controller.dart';

class AccountSettingsPage extends StatelessWidget {
  final LibraryController controller;
  final AccountService accountService;

  const AccountSettingsPage({
    super.key,
    required this.controller,
    required this.accountService,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.activeProfile?.childMode == true) {
      return Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'La configuración de cuenta no está disponible desde un perfil Kids.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Mi cuenta'),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF050505), Color(0xFF18130A), Color(0xFF090909)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              _AccountSummary(controller: controller),
              const SizedBox(height: 16),
              _AccountSection(
                title: 'Seguridad',
                children: [
                  _AccountAction(
                    icon: Icons.alternate_email_rounded,
                    label: 'Cambiar correo',
                    onTap: () => _changeEmail(context),
                  ),
                  _AccountAction(
                    icon: Icons.password_rounded,
                    label: 'Cambiar contraseña',
                    onTap: () => _changePassword(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AccountSection(
                title: 'Administración',
                children: [
                  _AccountAction(
                    icon: Icons.switch_account_rounded,
                    label: 'Administrar perfiles',
                    onTap: () => Navigator.pushNamed(context, '/profiles'),
                  ),
                  _AccountAction(
                    icon: Icons.devices_rounded,
                    label: 'Administrar dispositivos',
                    onTap: () => _showDevices(context),
                  ),
                  _AccountAction(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Planes',
                    onTap: () => _showPlans(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AccountSection(
                title: 'Sesión',
                children: [
                  _AccountAction(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión actual',
                    onTap: () => _logout(context),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _DangerZone(onDelete: () => _deleteAccount(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeEmail(BuildContext context) async {
    final newEmail = TextEditingController(text: controller.accountEmail);
    final password = TextEditingController();
    await _showCredentialDialog(
      context,
      title: 'Cambiar correo',
      fields: [
        _DialogField(controller: newEmail, label: 'Nuevo correo'),
        _DialogField(
          controller: password,
          label: 'Contraseña actual',
          secret: true,
        ),
      ],
      action: 'Actualizar correo',
      onSubmit: () async {
        await accountService.changeEmail(
          currentPassword: password.text,
          newEmail: newEmail.text,
        );
        await controller.load();
      },
    );
    newEmail.dispose();
    password.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmation = TextEditingController();
    await _showCredentialDialog(
      context,
      title: 'Cambiar contraseña',
      fields: [
        _DialogField(
          controller: current,
          label: 'Contraseña actual',
          secret: true,
        ),
        _DialogField(controller: next, label: 'Nueva contraseña', secret: true),
        _DialogField(
          controller: confirmation,
          label: 'Confirmar contraseña',
          secret: true,
        ),
      ],
      action: 'Actualizar contraseña',
      onSubmit: () async {
        if (next.text.length < 6 || next.text != confirmation.text) {
          throw Exception(
            'La confirmación no coincide o la contraseña es muy corta.',
          );
        }
        await accountService.changePassword(
          currentPassword: current.text,
          newPassword: next.text,
        );
      },
    );
    current.dispose();
    next.dispose();
    confirmation.dispose();
  }

  Future<void> _showDevices(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171511),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dispositivos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.devices_rounded, color: AppTheme.gold),
              title: Text('${defaultTargetPlatform.name} · dispositivo actual'),
              subtitle: const Text('Sesión activa en este dispositivo'),
            ),
            const SizedBox(height: 12),
            Text(
              'Límite del plan: ${controller.accountMaxDevices} dispositivos',
              style: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlans(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171511),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Planes Mini Read',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 14),
            _PlanLine(
              name: 'FREE',
              detail: '4 perfiles · 2 dispositivos · 20 monedas diarias',
            ),
            _PlanLine(
              name: 'PLUS',
              detail: '6 perfiles · 3 dispositivos · 50 monedas diarias',
            ),
            _PlanLine(
              name: 'PREMIUM',
              detail: '8 perfiles · 5 dispositivos · 100 monedas diarias',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    controller.clearUserState();
    await accountService.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Esta acción eliminará perfiles, historial, favoritos, chats IA, monedas y configuración. No puede deshacerse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;
    final password = TextEditingController();
    final confirmation = TextEditingController();
    await _showCredentialDialog(
      context,
      title: 'Confirmar eliminación',
      fields: [
        _DialogField(
          controller: password,
          label: 'Contraseña actual',
          secret: true,
        ),
        _DialogField(controller: confirmation, label: 'Escribe ELIMINAR'),
      ],
      action: 'Eliminar cuenta',
      destructive: true,
      onSubmit: () async {
        if (confirmation.text.trim() != 'ELIMINAR') {
          throw Exception('Escribe ELIMINAR para continuar.');
        }
        await accountService.deleteAccount(currentPassword: password.text);
        controller.clearUserState();
      },
      onSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      },
    );
    password.dispose();
    confirmation.dispose();
  }

  Future<void> _showCredentialDialog(
    BuildContext context, {
    required String title,
    required List<_DialogField> fields,
    required String action,
    required Future<void> Function() onSubmit,
    bool destructive = false,
    VoidCallback? onSuccess,
  }) async {
    String? error;
    bool saving = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: !destructive,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final field in fields) ...[
                TextField(
                  controller: field.controller,
                  obscureText: field.secret,
                  decoration: InputDecoration(labelText: field.label),
                ),
                const SizedBox(height: 10),
              ],
              if (error != null)
                Text(error!, style: const TextStyle(color: AppTheme.coral)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await onSubmit();
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        onSuccess?.call();
                      } catch (exception) {
                        setState(() {
                          saving = false;
                          error = exception
                              .toString()
                              .replaceFirst('Exception:', '')
                              .trim();
                        });
                      }
                    },
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: AppTheme.coral)
                  : null,
              child: Text(saving ? 'Procesando...' : action),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField {
  final TextEditingController controller;
  final String label;
  final bool secret;

  const _DialogField({
    required this.controller,
    required this.label,
    this.secret = false,
  });
}

class _AccountSummary extends StatelessWidget {
  final LibraryController controller;

  const _AccountSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    final createdAt = controller.accountCreatedAt;
    final memberSince = createdAt == null
        ? 'No disponible'
        : '${_month(createdAt.month)} ${createdAt.year}';
    return _AccountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuenta Mini Read',
            style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Correo', value: controller.accountEmail),
          _InfoRow(
            label: 'Plan',
            value: controller.accountMembership.toUpperCase(),
          ),
          _InfoRow(
            label: 'Perfiles',
            value:
                '${controller.readerProfiles.length} / ${controller.accountMaxProfiles}',
          ),
          _InfoRow(
            label: 'Dispositivos',
            value: '1 / ${controller.accountMaxDevices}',
          ),
          _InfoRow(label: 'Miembro desde', value: memberSince),
          _InfoRow(
            label: 'Suscripción',
            value: controller.accountSubscriptionStatus,
          ),
        ],
      ),
    );
  }

  String _month(int month) => const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ][month - 1];
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white54)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AccountSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _AccountSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => _AccountCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.gold,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

class _AccountAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AccountAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: AppTheme.gold),
    title: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
    onTap: onTap,
  );
}

class _DangerZone extends StatelessWidget {
  final VoidCallback onDelete;
  const _DangerZone({required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.coral.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.coral.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zona de riesgo',
          style: TextStyle(color: AppTheme.coral, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'La eliminación de cuenta es permanente.',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('Eliminar cuenta'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.coral,
            side: const BorderSide(color: AppTheme.coral),
          ),
        ),
      ],
    ),
  );
}

class _PlanLine extends StatelessWidget {
  final String name;
  final String detail;
  const _PlanLine({required this.name, required this.detail});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.workspace_premium_rounded, color: AppTheme.gold),
    title: Text(
      name,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
    ),
    subtitle: Text(detail),
  );
}

class _AccountCard extends StatelessWidget {
  final Widget child;
  const _AccountCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF171511).withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: child,
  );
}
