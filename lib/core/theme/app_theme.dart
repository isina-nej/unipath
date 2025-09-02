import 'package:flutter/material.dart';

/// کلاس مدیریت تم برنامه
/// این کلاس مسئولیت مدیریت تم‌های مختلف برنامه را بر عهده دارد
class AppTheme {
  // Private constructor
  AppTheme._();

  // نمونه Singleton
  static final AppTheme _instance = AppTheme._();
  static AppTheme get instance => _instance;

  /// دریافت تم بر اساس ColorScheme
  static ThemeData getTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      colorScheme: colorScheme,
    );
  }

  /// تم سفارشی برای دیالوگ‌ها
  static ThemeData getDialogTheme(ColorScheme colorScheme) {
    return getTheme(colorScheme);
  }
}
