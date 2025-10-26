import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pagina de Configuracion")),
      body: Text("Body de la config"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 4),
    );
  }
}
