import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF137A2A);
  static const Color darkGreen = Color(0xFF0D5C20);
  static const Color orange = Color(0xFFEF7413);
  static const Color background = Color(0xFFF6F8F6);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        primary: green,
        secondary: orange,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
