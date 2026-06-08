import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/reader_profile.dart';
import '../controllers/library_controller.dart';

const _profileGenres = [
  'Aventura',
  'Fantasia',
  'Ciencia ficcion',
  'Romance',
  'Misterio',
  'Infantil',
  'Historia',
  'Terror',
  'Suspenso',
  'Humor',
];

class ReaderProfileSelectorPage extends StatelessWidget {
  final LibraryController controller;

  const ReaderProfileSelectorPage({super.key, required this.controller});

  Future<void> _select(BuildContext context, ReaderProfile profile) async {
    final openedAsRoute = ModalRoute.of(context)?.settings.name == '/profiles';
    if (profile.pinEnabled && !profile.childMode) {
      if (!RegExp(r'^\d{4}$').hasMatch(profile.pinCode)) {
        _showSelectionError(
          context,
          'Este perfil tiene un PIN inválido. Edítalo antes de continuar.',
        );
        return;
      }
      final granted = await _requestPin(context, profile);
      if (!granted) return;
    }
    try {
      await controller.selectProfile(profile);
      if (openedAsRoute && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (_) {
      if (context.mounted) {
        _showSelectionError(
          context,
          'No pudimos abrir este perfil. Inténtalo nuevamente.',
        );
      }
    }
  }

  Future<bool> _requestPin(BuildContext context, ReaderProfile profile) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _PinDialog(profile: profile),
    );
    return result == true;
  }

  void _showSelectionError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  void _add(BuildContext context) {
    if (!controller.canCreateProfile) {
      _showLimitMessage(context);
      return;
    }
    Navigator.pushNamed(context, '/create-profile');
  }

  void _showLimitMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Has alcanzado el límite de perfiles de tu plan.'),
      ),
    );
  }

  Future<void> _edit(BuildContext context, ReaderProfile profile) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _EditReaderProfileSheet(controller: controller, profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: controller.activeProfile?.childMode == true
            ? const []
            : [
                IconButton(
                  tooltip: 'Cuenta y configuración',
                  onPressed: () => Navigator.pushNamed(context, '/account'),
                  icon: const Icon(Icons.manage_accounts_rounded),
                ),
              ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050505), Color(0xFF17130B), Color(0xFF080808)],
          ),
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      color: AppTheme.gold,
                      size: 42,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Quién está leyendo?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solo los perfiles lectores aparecen aquí.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 28,
                      children: [
                        for (final profile in controller.readerProfiles)
                          _ProfileTile(
                            profile: profile,
                            onTap: () => _select(context, profile),
                            onEdit: controller.activeProfile?.childMode == true
                                ? null
                                : () => _edit(context, profile),
                          ),
                        if (controller.canCreateProfile &&
                            controller.activeProfile?.childMode != true)
                          _AddTile(onTap: () => _add(context)),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Text(
                      '${controller.readerProfiles.length} de ${controller.accountMaxProfiles} perfiles',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (controller.activeProfile?.childMode != true)
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/account'),
                        icon: const Icon(Icons.manage_accounts_rounded),
                        label: const Text('Cuenta y configuración'),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  final ReaderProfile profile;

  const _PinDialog({required this.profile});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _validate() {
    if (_pinController.text == widget.profile.pinCode) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _error = 'El PIN ingresado es incorrecto.');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.lock_rounded, color: AppTheme.gold, size: 34),
      title: Text('Perfil protegido: ${widget.profile.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa el PIN de 4 dígitos para continuar.'),
          const SizedBox(height: 14),
          TextField(
            controller: _pinController,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onSubmitted: (_) => _validate(),
            decoration: InputDecoration(
              labelText: 'PIN',
              errorText: _error,
              prefixIcon: const Icon(Icons.pin_rounded),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _validate,
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Entrar'),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final ReaderProfile profile;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _ProfileTile({
    required this.profile,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: _ProfileAvatar(profile: profile),
              ),
              if (profile.pinEnabled && !profile.childMode)
                const Positioned(
                  left: 8,
                  top: 8,
                  child: _ProfileTypeIcon(icon: Icons.lock_rounded),
                )
              else if (profile.childMode)
                const Positioned(
                  left: 8,
                  top: 8,
                  child: _ProfileTypeIcon(icon: Icons.child_care_rounded),
                ),
              if (onEdit != null)
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: IconButton.filled(
                    tooltip: 'Editar perfil',
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF28241A),
                      foregroundColor: AppTheme.gold,
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (profile.childMode)
            const _ProfileBadge(icon: Icons.child_care_rounded, label: 'KIDS')
          else if (profile.pinEnabled)
            const _ProfileBadge(icon: Icons.lock_rounded, label: 'PROTEGIDO'),
        ],
      ),
    );
  }
}

class _ProfileTypeIcon extends StatelessWidget {
  final IconData icon;

  const _ProfileTypeIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.55)),
      ),
      child: Icon(icon, color: AppTheme.gold, size: 17),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.gold, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ReaderProfile profile;
  final Uint8List? bytes;

  const _ProfileAvatar({required this.profile, this.bytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        color: Color(profile.accentColor),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes != null
          ? Image.memory(bytes!, fit: BoxFit.cover)
          : profile.avatarUrl.isNotEmpty
          ? Image.network(
              profile.avatarUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => _ProfileFallback(profile: profile),
            )
          : _ProfileFallback(profile: profile),
    );
  }
}

class _ProfileFallback extends StatelessWidget {
  final ReaderProfile profile;

  const _ProfileFallback({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        profile.name.trim().isEmpty
            ? '?'
            : profile.name.trim().substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 46,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 136,
        child: Column(
          children: [
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(Icons.add_rounded, color: AppTheme.gold, size: 54),
            ),
            const SizedBox(height: 14),
            Text(
              'AGREGAR PERFIL',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditReaderProfileSheet extends StatefulWidget {
  final LibraryController controller;
  final ReaderProfile profile;

  const _EditReaderProfileSheet({
    required this.controller,
    required this.profile,
  });

  @override
  State<_EditReaderProfileSheet> createState() =>
      _EditReaderProfileSheetState();
}

class _EditReaderProfileSheetState extends State<_EditReaderProfileSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late Set<String> _genres;
  late bool _isKids;
  late bool _pinEnabled;
  late final TextEditingController _pinController;
  Uint8List? _avatarBytes;
  String _contentType = 'image/jpeg';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _genres = widget.profile.favoriteCategories.toSet();
    _isKids = widget.profile.childMode;
    _pinEnabled = widget.profile.pinEnabled;
    _pinController = TextEditingController(text: widget.profile.pinCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 86,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _contentType = picked.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe un nombre para el perfil.');
      return;
    }
    if (!_isKids &&
        _pinEnabled &&
        !RegExp(r'^\d{4}$').hasMatch(_pinController.text)) {
      setState(() => _error = 'El PIN debe contener exactamente 4 dígitos.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var profile = widget.profile.copyWith(
        name: name,
        role: _isKids ? 'child' : 'adult',
        ageGroup: _isKids ? 'Ninos' : 'Adultos',
        childMode: _isKids,
        pinEnabled: _isKids ? false : _pinEnabled,
        pinCode: _isKids ? '' : _pinController.text,
        favoriteCategories: _genres.toList(),
      );
      if (_avatarBytes != null) {
        final url = await widget.controller.uploadReaderProfileAvatar(
          profileId: profile.id,
          imageBytes: _avatarBytes!,
          contentType: _contentType,
        );
        profile = profile.copyWith(avatarUrl: url);
      }
      await widget.controller.updateReaderProfile(profile);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception:', '').trim(),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text('Se eliminará el perfil "${widget.profile.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    await widget.controller.deleteReaderProfile(widget.profile.id);
    if (!mounted) return;
    Navigator.pop(context);
    if (widget.controller.readerProfiles.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/create-main-profile',
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.profile.copyWith(
      name: _nameController.text,
      childMode: _isKids,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Material(
        color: const Color(0xFF171511),
        borderRadius: BorderRadius.circular(22),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Editar perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _saving ? null : _pickAvatar,
                  child: _ProfileAvatar(profile: preview, bytes: _avatarBytes),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                enabled: !_saving,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre del perfil',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isKids,
                onChanged: _saving
                    ? null
                    : (value) => setState(() {
                        _isKids = value;
                        if (value) _pinEnabled = false;
                      }),
                title: const Text(
                  'Perfil Kids',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _isKids
                      ? 'Mostrara solo libros infantiles.'
                      : 'Mostrara solo libros para adultos.',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _pinEnabled,
                onChanged: _saving || _isKids
                    ? null
                    : (value) => setState(() => _pinEnabled = value),
                title: const Text(
                  'Proteger con PIN',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: null,
              ),
              if (!_isKids && _pinEnabled)
                TextField(
                  controller: _pinController,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'PIN de 4 dÃ­gitos',
                    prefixIcon: Icon(Icons.pin_rounded),
                  ),
                ),
              const SizedBox(height: 10),
              const Text(
                'Géneros favoritos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final genre in _profileGenres)
                    FilterChip(
                      selected: _genres.contains(genre),
                      label: Text(genre),
                      onSelected: _saving
                          ? null
                          : (selected) {
                              setState(() {
                                selected
                                    ? _genres.add(genre)
                                    : _genres.remove(genre);
                              });
                            },
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppTheme.coral)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _saving ? null : _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Eliminar perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
