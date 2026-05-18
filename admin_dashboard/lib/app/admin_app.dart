import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';
import '../screens/admin_shell.dart';
import '../screens/login_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, admin, _) {
        final baseText = GoogleFonts.interTextTheme();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Admin Core',
          themeMode: admin.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
              error: AppColors.error,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.background,
            textTheme: baseText.apply(
              bodyColor: AppColors.onSurface,
              displayColor: AppColors.onSurface,
            ),
            useMaterial3: true,
            cardTheme: CardThemeData(
              color: AppColors.surfaceContainerLowest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.secondaryContainer,
              secondary: AppColors.secondaryContainer,
              surface: AppColors.darkSurface,
              error: AppColors.error,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: AppColors.darkBackground,
            textTheme: baseText.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            useMaterial3: true,
            cardTheme: CardThemeData(
              color: AppColors.darkSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          home: Consumer<AuthController>(
            builder: (context, auth, _) {
              return switch (auth.status) {
                AuthStatus.checking => const _BootScreen(),
                AuthStatus.signedIn => const AdminShell(),
                AuthStatus.signedOut ||
                AuthStatus.forbidden => const LoginScreen(),
              };
            },
          ),
        );
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
