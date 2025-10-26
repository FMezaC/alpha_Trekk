import 'package:alpha_treck/presentation/home/home_page.dart';
import 'package:alpha_treck/presentation/iteneraries/itenerarie_page.dart';
import 'package:alpha_treck/presentation/profile/profile_page.dart';
import 'package:alpha_treck/presentation/routes/routes_page.dart';
import 'package:alpha_treck/presentation/settings/settings_page.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, this.currentIndex = 0});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Evita recargar la misma página

    Widget page;

    switch (index) {
      case 1:
        page = const RoutesPage();
        break;
      case 2:
        page = const ItenerariePage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      case 4:
        page = const SettingsPage();
        break;
      default:
        page = const HomePage();
    }

    // Navegación reemplazando la pantalla actual
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: 'Routes'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
