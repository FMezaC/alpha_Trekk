import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ItenerariePage extends StatelessWidget {
  const ItenerariePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Itenerarios")),
      body: Text("Cuerpo del Itenerario"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}
