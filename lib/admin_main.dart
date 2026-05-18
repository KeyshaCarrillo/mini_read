import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin/presentation/admin_dashboard_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MiniReadAdminApp());
}

class MiniReadAdminApp extends StatelessWidget {
  const MiniReadAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Read Admin',
      home: AdminDashboardPage(),
    );
  }
}
