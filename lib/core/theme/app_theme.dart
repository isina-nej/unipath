import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(ColorScheme colorScheme) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20),
      ),
      colorScheme: colorScheme,
    );
  }
}
