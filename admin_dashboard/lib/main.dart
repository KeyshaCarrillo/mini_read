import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'app/admin_app.dart';
import 'controllers/admin_controller.dart';
import 'controllers/auth_controller.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'services/admin_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final apiService = AdminApiService(baseUrl: AppConstants.apiBaseUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(apiService)..bootstrap(),
        ),
        ChangeNotifierProvider(create: (_) => AdminController(apiService)),
      ],
      child: ResponsiveBreakpoints.builder(
        breakpoints: const [
          Breakpoint(start: 0, end: 650, name: MOBILE),
          Breakpoint(start: 651, end: 1024, name: TABLET),
          Breakpoint(start: 1025, end: double.infinity, name: DESKTOP),
        ],
        child: const AdminApp(),
      ),
    ),
  );
}
