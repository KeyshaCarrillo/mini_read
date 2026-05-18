import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/library/domain/entities/book.dart';
import '../features/library/presentation/controllers/home_controller.dart';
import '../features/library/presentation/controllers/library_controller.dart';
import '../features/library/presentation/pages/book_detail_page.dart';
import '../features/library/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/onboarding_preferences_page.dart';
import '../features/library/presentation/pages/profile_selection_page.dart';
import '../features/library/presentation/pages/reading_page.dart';
import 'app_theme.dart';
import 'auth_gate.dart';

class MiniReadApp extends StatelessWidget {
  final AuthController authController;
  final LibraryController libraryController;

  const MiniReadApp({
    super.key,
    required this.authController,
    required this.libraryController,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>.value(
      value: libraryController,
      child: MaterialApp(
        title: 'Mini Read',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              switch (settings.name) {
                case '/register':
                  return RegisterPage(
                    controller: authController,
                    libraryController: libraryController,
                  );
                case '/onboarding':
                  return OnboardingPreferencesPage(
                    controller: libraryController,
                  );
                case '/profiles':
                  return ProfileSelectionPage(controller: libraryController);
                case '/home':
                  return const HomeScreen();
                case '/book':
                  final book = settings.arguments! as Book;
                  return BookDetailPage(
                    controller: libraryController,
                    book: book,
                  );
                case '/read':
                  final book = settings.arguments! as Book;
                  return ReadingPage(controller: libraryController, book: book);
                default:
                  return AuthGate(
                    authController: authController,
                    libraryController: libraryController,
                  );
              }
            },
          );
        },
      ),
    );
  }
}
