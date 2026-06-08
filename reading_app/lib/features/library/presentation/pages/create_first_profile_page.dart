import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/app_theme.dart';
import '../controllers/library_controller.dart';

class CreateMainProfilePage extends StatefulWidget {
  final LibraryController controller;

  const CreateMainProfilePage({super.key, required this.controller});

  @override
  State<CreateMainProfilePage> createState() => _CreateMainProfilePageState();
}

class CreateFirstProfilePage extends CreateMainProfilePage {
  const CreateFirstProfilePage({super.key, required super.controller});
}

class _CreateMainProfilePageState extends State<CreateMainProfilePage> {
  static const _genres = [
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

  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  final _selectedGenres = <String>{};
  Uint8List? _avatarBytes;
  String _avatarContentType = 'image/jpeg';
  bool _isKids = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
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
      _avatarContentType = picked.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe un nombre para el perfil.');
      return;
    }
    if (!widget.controller.canCreateProfile) {
      setState(
        () => _error = 'Has alcanzado el limite de perfiles de tu plan actual.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var profile = await widget.controller.createProfile(
        OnboardingProfileDraft(
          name: name,
          ageGroup: _isKids ? 'Ninos' : 'Adultos',
          readingMood: _isKids
              ? 'Historias seguras para pequenos lectores'
              : 'Quiero descubrir buenos libros',
          favoriteCategories: _selectedGenres.toList(),
        ),
      );
      if (_avatarBytes != null) {
        final url = await widget.controller.uploadReaderProfileAvatar(
          profileId: profile.id,
          imageBytes: _avatarBytes!,
          contentType: _avatarContentType,
        );
        profile = profile.copyWith(avatarUrl: url);
        await widget.controller.updateReaderProfile(profile);
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/profiles', (_) => false);
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

  @override
  Widget build(BuildContext context) {
    final isMainProfile = widget.controller.readerProfiles.isEmpty;
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          isMainProfile ? 'Crear perfil principal' : 'Agregar perfil',
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _CreateProfileBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171511).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.36),
                        blurRadius: 34,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMainProfile
                            ? 'Crear perfil principal'
                            : 'Agregar perfil lector',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isMainProfile
                            ? 'La cuenta está lista. Ahora crea tu espacio de lectura.'
                            : 'Personaliza otro espacio de lectura.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.64),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: _saving ? null : _pickAvatar,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: AppTheme.midnight,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppTheme.gold,
                                width: 2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _avatarBytes == null
                                ? const Icon(
                                    Icons.add_a_photo_rounded,
                                    color: AppTheme.gold,
                                    size: 36,
                                  )
                                : Image.memory(
                                    _avatarBytes!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
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
                            : (value) => setState(() => _isKids = value),
                        title: const Text(
                          'Perfil Kids',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: _isKids
                            ? const Text(
                                'Este perfil mostrara solo libros infantiles.',
                              )
                            : const Text(
                                'Este perfil mostrara solo libros para adultos.',
                              ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Generos favoritos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final genre in _genres)
                            FilterChip(
                              selected: _selectedGenres.contains(genre),
                              label: Text(genre),
                              onSelected: _saving
                                  ? null
                                  : (selected) {
                                      setState(() {
                                        selected
                                            ? _selectedGenres.add(genre)
                                            : _selectedGenres.remove(genre);
                                      });
                                    },
                            ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: AppTheme.coral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            _saving ? 'Creando perfil...' : 'Continuar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateProfileBackdrop extends StatelessWidget {
  const _CreateProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF050505), Color(0xFF18130A), Color(0xFF090909)],
        ),
      ),
    );
  }
}
