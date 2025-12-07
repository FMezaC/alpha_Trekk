import 'package:flutter/material.dart';
import '../presentation/login/start_page.dart';

/// Navega a la pantalla de login
void navigateToLogin(BuildContext context) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const StartPage(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
