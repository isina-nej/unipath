import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/colors.dart';

class DarkModeController extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Singleton pattern
  static final DarkModeController instance = DarkModeController._internal();

  factory DarkModeController() => instance;

  DarkModeController._internal();

  static DarkModeController get shared => instance;

  // Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  // Get menu button colors based on dark mode state
  Color getMenuButtonStartColor(String buttonType) {
    if (_isDarkMode) {
      switch (buttonType) {
        case 'courseSelection':
          return AppColors.darkCourseSelectionStartColor;
        case 'schedule':
          return AppColors.darkScheduleStartColor;
        case 'grades':
          return AppColors.darkGradesStartColor;
        case 'messages':
          return AppColors.darkMessagesStartColor;
        case 'nextTerm':
          return AppColors.darkNextTermStartColor;
        case 'dormitory':
          return AppColors.darkDormitoryStartColor;
        default:
          return AppColors.darkPrimary;
      }
    } else {
      switch (buttonType) {
        case 'courseSelection':
          return AppColors.courseSelectionStartColor;
        case 'schedule':
          return AppColors.scheduleStartColor;
        case 'grades':
          return AppColors.gradesStartColor;
        case 'messages':
          return AppColors.messagesStartColor;
        case 'nextTerm':
          return AppColors.nextTermStartColor;
        case 'dormitory':
          return AppColors.dormitoryStartColor;
        default:
          return AppColors.indigo;
      }
    }
  }

  Color getMenuButtonEndColor(String buttonType) {
    if (_isDarkMode) {
      switch (buttonType) {
        case 'courseSelection':
          return AppColors.darkCourseSelectionEndColor;
        case 'schedule':
          return AppColors.darkScheduleEndColor;
        case 'grades':
          return AppColors.darkGradesEndColor;
        case 'messages':
          return AppColors.darkMessagesEndColor;
        case 'nextTerm':
          return AppColors.darkNextTermEndColor;
        case 'dormitory':
          return AppColors.darkDormitoryEndColor;
        default:
          return AppColors.darkAccent;
      }
    } else {
      switch (buttonType) {
        case 'courseSelection':
          return AppColors.courseSelectionEndColor;
        case 'schedule':
          return AppColors.scheduleEndColor;
        case 'grades':
          return AppColors.gradesEndColor;
        case 'messages':
          return AppColors.messagesEndColor;
        case 'nextTerm':
          return AppColors.nextTermEndColor;
        case 'dormitory':
          return AppColors.dormitoryEndColor;
        default:
          return AppColors.blue;
      }
    }
  }

  // Get theme data based on dark mode state
  ThemeData get themeData {
    if (_isDarkMode) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.darkPrimary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCardBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkAppBarBackground,
          foregroundColor: AppColors.darkText,
          iconTheme: IconThemeData(color: AppColors.darkIcon),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkText),
          bodyMedium: TextStyle(color: AppColors.darkText),
          titleLarge: TextStyle(color: AppColors.darkText),
          titleMedium: TextStyle(color: AppColors.darkTextSecondary),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkIcon),
        dividerColor: AppColors.darkDivider,
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkAccent,
          surface: AppColors.darkSurface,
          error: AppColors.darkError,
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.white,
        cardColor: AppColors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          foregroundColor: AppColors.white,
          iconTheme: IconThemeData(color: AppColors.white),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.black87),
          bodyMedium: TextStyle(color: AppColors.black87),
          titleLarge: TextStyle(color: AppColors.black),
          titleMedium: TextStyle(color: AppColors.black54),
        ),
        iconTheme: const IconThemeData(color: AppColors.black87),
        dividerColor: AppColors.greyWithOpacity30,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.blue,
          surface: AppColors.white,
          error: AppColors.errorText,
        ),
      );
    }
  }
}
