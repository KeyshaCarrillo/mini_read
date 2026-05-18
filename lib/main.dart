//lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app/mini_read_app.dart';
import 'features/auth/data/datasources/firebase_auth_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/library/data/datasources/book_api_datasource.dart';
import 'features/library/data/datasources/firebase_library_datasource.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/usecases/get_books.dart';
import 'features/library/domain/usecases/get_profiles.dart';
import 'features/library/presentation/controllers/library_controller.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authDataSource = FirebaseAuthDataSourceImpl(
    fb.FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
  final authRepository = AuthRepositoryImpl(authDataSource);
  final authController = AuthController(
    loginUser: LoginUser(authRepository),
    registerUser: RegisterUser(authRepository),
  );

  final libraryRepository = LibraryRepositoryImpl(
    bookApiDataSource: BookApiDataSource(
      client: http.Client(),

      baseUrl: dotenv.env['BOOK_API_BASE_URL'] ?? '',
    ),
    firebaseDataSource: FirebaseLibraryDataSource(
      firestore: FirebaseFirestore.instance,
      auth: fb.FirebaseAuth.instance,
    ),
  );
  final libraryController = LibraryController(
    repository: libraryRepository,
    getBooks: GetBooks(libraryRepository),
    getProfiles: GetProfiles(libraryRepository),
  );

  runApp(
    MiniReadApp(
      authController: authController,
      libraryController: libraryController,
    ),
  );
}
