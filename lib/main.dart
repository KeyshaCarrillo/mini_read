import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'app/mini_read_app.dart';
import 'features/auth/data/datasources/firebase_auth_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/library/data/datasources/local_library_datasource.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/usecases/get_books.dart';
import 'features/library/domain/usecases/get_profiles.dart';
import 'features/library/presentation/controllers/library_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authDataSource = FirebaseAuthDataSourceImpl(fb.FirebaseAuth.instance);
  final authRepository = AuthRepositoryImpl(authDataSource);
  final authController = AuthController(
    loginUser: LoginUser(authRepository),
    registerUser: RegisterUser(authRepository),
  );

  final libraryRepository = LibraryRepositoryImpl(LocalLibraryDataSource());
  final libraryController = LibraryController(
    getBooks: GetBooks(libraryRepository),
    getProfiles: GetProfiles(libraryRepository),
  );
  await libraryController.load();

  runApp(
    MiniReadApp(
      authController: authController,
      libraryController: libraryController,
    ),
  );
}
