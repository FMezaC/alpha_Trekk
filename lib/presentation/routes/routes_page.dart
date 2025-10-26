import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Routes Pages")),
      body: Text("Estas en la paginas de rutas"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
