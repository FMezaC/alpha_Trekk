import 'package:flutter/material.dart';

const Color blueLight = Color(0xFF007BFF);
const Color green = Color(0xFF4CAF50);
const Color white = Color(0xFFFFFFFF);
const Color blackDark = Color(0xFF212121);
const Color grayDark = Color(0xFF757575);
const Color orange = Color(0xFFFF9800);
const Color greenDark = Color(0xFF00695C);
const Color grayLight = Color(0xFFEEEEEE);
const Color blueDark = Color(0xFF1565C0);
const Color red = Color(0xFFF44336);
const List<Color> colorThemes = [
  blueDark,
  blueLight,
  green,
  white,
  blackDark,
  grayDark,
  orange,
  greenDark,
  grayLight,
  red,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
    : assert(
        selectedColor >= 0 && selectedColor < colorThemes.length,
        "colores entre 0 y ${colorThemes.length}",
      );
  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: colorThemes[selectedColor],
      appBarTheme: AppBarTheme(
        backgroundColor: colorThemes[selectedColor],
        foregroundColor: Colors.white,
      ),
    );
  }
}
