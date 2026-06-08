import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/library/presentation/controllers/library_controller.dart';
import '../features/library/presentation/pages/create_first_profile_page.dart';
import '../features/library/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/reader_profile_selector_page.dart';

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
      initialData: fb.FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? fb.FirebaseAuth.instance.currentUser;
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
  Future<void>? _loadFuture;
  String? _loadedUid;

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant _AuthenticatedLibrary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadedUid == widget.uid) return;
      setState(() {
        _loadFuture = _load();
      });
    });
  }

  Future<void> _load() async {
    if (_loadedUid == widget.uid) return;
    _loadedUid = widget.uid;
    await widget.controller.load();
  }

  void _retry() {
    setState(() {
      _loadedUid = null;
      _loadFuture = null;
    });
    _scheduleLoad();
  }

  @override
  Widget build(BuildContext context) {
    final loadFuture = _loadFuture;
    if (loadFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<void>(
      future: loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (widget.controller.loadError != null) {
          return _InitialLoadError(
            message: widget.controller.loadError!,
            onRetry: _retry,
          );
        }
        if (widget.controller.readerProfiles.isEmpty) {
          return CreateMainProfilePage(controller: widget.controller);
        }
        if (widget.controller.activeProfile != null) {
          return const HomeScreen();
        }
        return ReaderProfileSelectorPage(controller: widget.controller);
      },
    );
  }
}

class _InitialLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InitialLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 54),
                const SizedBox(height: 18),
                const Text(
                  'No pudimos cargar Mini Read',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
