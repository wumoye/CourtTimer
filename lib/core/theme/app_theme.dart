import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData buildTheme(Brightness brightness) {
    final seed = Colors.orange;
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: TextStyle(color: Colors.white70),
        headlineMedium: TextStyle(color: Colors.white),
      ),
    );
  }
}
