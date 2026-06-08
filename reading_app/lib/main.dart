//lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/mini_read_app.dart';
import 'core/services/auth_service.dart';
import 'core/services/account_service.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/firestore_service.dart';
import 'features/auth/data/datasources/firebase_auth_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/library/data/datasources/firebase_library_datasource.dart';
import 'features/library/data/repositories/firestore_book_repository.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/data/services/user_book_service.dart';
import 'features/library/domain/usecases/get_books.dart';
import 'features/library/domain/usecases/get_profiles.dart';
import 'features/library/presentation/controllers/library_controller.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService(fb.FirebaseAuth.instance);
  final firestoreService = FirestoreService(FirebaseFirestore.instance);
  final cloudinaryService = CloudinaryService(
    cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
    uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
  );
  final accountService = AccountService(
    auth: fb.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );

  final authDataSource = FirebaseAuthDataSourceImpl(
    authService,
    firestoreService,
  );
  final authRepository = AuthRepositoryImpl(authDataSource);
  final authController = AuthController(
    loginUser: LoginUser(authRepository),
    registerUser: RegisterUser(authRepository),
  );

  final bookRepository = FirestoreBookRepository(
    firestore: FirebaseFirestore.instance,
  );
  final userBookService = UserBookService(
    firestore: FirebaseFirestore.instance,
    auth: fb.FirebaseAuth.instance,
  );
  final libraryRepository = LibraryRepositoryImpl(
    bookRepository: bookRepository,
    firebaseDataSource: FirebaseLibraryDataSource(
      firestore: FirebaseFirestore.instance,
      auth: fb.FirebaseAuth.instance,
      firestoreService: firestoreService,
      cloudinaryService: cloudinaryService,
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
      accountService: accountService,
      bookRepository: bookRepository,
      userBookService: userBookService,
    ),
  );
}
