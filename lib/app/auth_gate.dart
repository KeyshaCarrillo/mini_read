import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/library/presentation/controllers/library_controller.dart';
import '../features/library/presentation/pages/profile_selection_page.dart';

class AuthGate extends StatelessWidget {
  final AuthController authController;
  final LibraryController libraryController;

  const AuthGate({
    super.key,
    required this.authController,
    required this.libraryController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb.User?>(
      stream: fb.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return ProfileSelectionPage(controller: libraryController);
        }

        return LoginPage(controller: authController);
      },
    );
  }
}
