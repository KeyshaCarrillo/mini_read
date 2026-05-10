import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mini Read'),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesion',
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const Text(
                  'Quien va a leer?',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hasta 4 perfiles por cuenta. En esta v1 dejamos tres perfiles demo y luego los guardamos en Firebase.',
                  style: TextStyle(
                    color: AppTheme.ink.withValues(alpha: 0.68),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final profile in controller.profiles)
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          controller.selectProfile(profile);
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              Container(
                                height: 126,
                                decoration: BoxDecoration(
                                  color: Color(profile.accentColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    profile.name.substring(0, 1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                profile.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                profile.ageGroup,
                                style: TextStyle(
                                  color: AppTheme.ink.withValues(alpha: 0.58),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 150,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Agregar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
