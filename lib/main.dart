import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mini_read/app/routes.dart';
import 'package:mini_read/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
