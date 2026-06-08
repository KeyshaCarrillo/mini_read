import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../core/services/account_service.dart';
import '../features/library/domain/entities/book.dart';
import '../features/library/domain/repositories/book_repository.dart';
import '../features/library/data/services/user_book_service.dart';
import '../features/library/presentation/controllers/home_controller.dart';
import '../features/library/presentation/controllers/library_controller.dart';
import '../features/library/presentation/pages/book_detail_page.dart';
import '../features/library/presentation/pages/book_reader_screen.dart';
import '../features/library/presentation/pages/books_screen.dart';
import '../features/library/presentation/pages/account_settings_page.dart';
import '../features/library/presentation/pages/create_first_profile_page.dart';
import '../features/library/presentation/pages/favorites_screen.dart';
import '../features/library/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/infantil_screen.dart';
import '../features/library/presentation/pages/onboarding_preferences_page.dart';
import '../features/library/presentation/pages/profile_selection_page.dart';
import '../features/library/presentation/pages/reader_profile_selector_page.dart';
import '../features/library/presentation/pages/reading_page.dart';
import 'app_theme.dart';
import 'auth_gate.dart';

class MiniReadApp extends StatelessWidget {
  final AuthController authController;
  final LibraryController libraryController;
  final AccountService accountService;
  final BookRepository bookRepository;
  final UserBookService userBookService;

  const MiniReadApp({
    super.key,
    required this.authController,
    required this.libraryController,
    required this.accountService,
    required this.bookRepository,
    required this.userBookService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Read',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return ChangeNotifierProvider<HomeController>.value(
          value: libraryController,
          child: child ?? const SizedBox.shrink(),
        );
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            switch (settings.name) {
              case '/register':
                return RegisterScreen(libraryController: libraryController);
              case '/onboarding':
                return OnboardingPreferencesPage(controller: libraryController);
              case '/create-first-profile':
              case '/create-main-profile':
              case '/create-profile':
                return CreateMainProfilePage(controller: libraryController);
              case '/profiles':
                return ReaderProfileSelectorPage(controller: libraryController);
              case '/profile':
                return ProfileSelectionPage(controller: libraryController);
              case '/account':
                return AccountSettingsPage(
                  controller: libraryController,
                  accountService: accountService,
                );
              case '/home':
                return const HomeScreen();
              case '/books':
                return BooksScreen(
                  repository: bookRepository,
                  userBookService: userBookService,
                );
              case '/adultos':
                return BooksScreen(
                  repository: bookRepository,
                  userBookService: userBookService,
                  initialCategory: 'adult',
                );
              case '/favorites':
                return FavoritesScreen(
                  repository: bookRepository,
                  userBookService: userBookService,
                );
              case '/infantil':
                return InfantilScreen(repository: bookRepository);
              case '/book-reader':
              case '/pdf-reader':
                final book = settings.arguments! as Book;
                return BookReaderScreen(
                  book: book,
                  userBookService: userBookService,
                );
              case '/book':
                final book = settings.arguments! as Book;
                return BookDetailPage(
                  controller: libraryController,
                  book: book,
                  userBookService: userBookService,
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
    );
  }
}
