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

        final user = snapshot.data;
        if (user == null) {
          return LoginPage(controller: authController);
        }

        return _AuthenticatedLibrary(
          uid: user.uid,
          controller: libraryController,
        );
      },
    );
  }
}

class _AuthenticatedLibrary extends StatefulWidget {
  final String uid;
  final LibraryController controller;

  const _AuthenticatedLibrary({required this.uid, required this.controller});

  @override
  State<_AuthenticatedLibrary> createState() => _AuthenticatedLibraryState();
}

class _AuthenticatedLibraryState extends State<_AuthenticatedLibrary> {
  late Future<void> _loadFuture;
  String? _loadedUid;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  @override
  void didUpdateWidget(covariant _AuthenticatedLibrary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _loadFuture = _load();
    }
  }

  Future<void> _load() async {
    if (_loadedUid == widget.uid) return;
    _loadedUid = widget.uid;
    await widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ProfileSelectionPage(controller: widget.controller);
      },
    );
  }
}
