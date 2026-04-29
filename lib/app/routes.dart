import 'package:flutter/material.dart';
import 'package:mini_read/features/auth/presentation/pages/login_page.dart';
import 'package:mini_read/features/home/presentation/pages/home_page.dart';

class AppRoutes {
  static const login = '/';
  static const home = '/home';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    home: (_) => const HomePage(),
  };
}
