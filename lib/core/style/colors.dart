import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color blackWithOpacity10 = Color(0x1A000000);

  // Primary Theme Colors
  static const Color blue = Colors.blue;
  static const Color indigo = Colors.indigo;
  static const Color indigoAccent = Colors.indigoAccent;
  // static const Color appBarBackground = indigo;
  static const Color appBarText = white;
  static const Color cardBackground = white;

  // Light Mode Colors
  static const Color greyWithOpacity30 = Color(0x4DDCDCDC);
  static const Color redShade100 = Colors.redAccent;
  static const Color blueShade100 = Colors.blueAccent;
  static const Color greenShade100 = Colors.greenAccent;
  static const Color yellowShade100 = Colors.yellowAccent;
  static const Color orangeShade100 = Colors.orangeAccent;
  static const Color purpleShade100 = Colors.purpleAccent;
  static const Color tealShade100 = Colors.tealAccent;
  static const Color pinkShade100 = Colors.pinkAccent;

  // Additional Light Mode Colors
  static const Color blueShade50 = Color(0xFFE3F2FD);
  static const Color cyanShade100 = Color(0xFFB2EBF2);

  // Light Mode Selected Colors
  static const Color redShade700 = Color(0xFFD32F2F);
  static const Color pinkShade700 = Color(0xFFC2185B);
  static const Color blueShade900 = Color(0xFF0D47A1);
  static const Color greenShade700 = Color(0xFF388E3C);
  static const Color cyanShade700 = Color(0xFF0097A7);
  static const Color orangeShade700 = Color(0xFFF57C00);
  static const Color purpleShade700 = Color(0xFF7B1FA2);
  static const Color tealShade800 = Color(0xFF00695C);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  // static const Color darkPrimary = Color(0xFF3F51B5);
  static const Color darkAccent = Color(0xFF64B5F6);
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xB3FFFFFF);
  static const Color darkDivider = Color(0x1FFFFFFF);
  static const Color darkIcon = Color(0xFFFFFFFF);
  static const Color darkIconInactive = Color(0x61FFFFFF);
  static const Color darkAppBarBackground = Color(0xFF1A1A1A);
  static const Color darkError = Color(0xFFCF6679);

  // Dark Mode Selected Colors
  static const Color darkRedSelected = Color(0xFFB71C1C);
  static const Color darkPinkSelected = Color(0xFF880E4F);
  static const Color darkBlueSelected = Color(0xFF0D47A1);
  static const Color darkGreenSelected = Color(0xFF1B5E20);
  static const Color darkCyanSelected = Color(0xFF004D40);
  static const Color darkOrangeSelected = Color(0xFFE65100);
  static const Color darkPurpleSelected = Color(0xFF4A148C);
  static const Color darkTealSelected = Color(0xFF004D40);

  // Dark Mode Schedule Colors
  static const Color darkScheduleBackground = Color(0xFF121212);
  static const Color darkScheduleCardBackground = Color(0xFF1E1E1E);
  static const Color darkScheduleTimeIndicator = Color(0xFF64B5F6);

  // Dormitory Colors - Light Mode
  static const Color dormitoryStartColor = Color(0xFF26A69A);
  static const Color dormitoryEndColor = Color(0xFF00796B);
  static const Color blockBackground = white;
  // static const Color blockBorder = indigo;
  static const Color floorCardBackground = white;
  // static const Color floorCardBorder = blue;
  static const Color floorText = black87;

  // Dormitory Colors - Dark Mode
  static const Color darkDormitoryStartColor = Color(0xFF00695C);
  static const Color darkDormitoryEndColor = Color(0xFF004D40);
  static const Color darkBlockBackground = Color(0xFF2D2D2D);
  // static const Color darkBlockBorder = darkAccent;
  static const Color darkFloorCardBackground = Color(0xFF1E1E1E);
  // static const Color darkFloorCardBorder = darkAccent;
  static const Color darkFloorText = darkText;

  // Login Colors
  static const Color loginGradientStart = indigo;
  static const Color loginGradientEnd = indigoAccent;
  static const Color loginButtonBackground = indigo;
  static const Color loginButtonText = white;

  // Dark Mode Login Colors
  static const Color darkLoginGradientStart = Color(0xFF1A237E);
  static const Color darkLoginGradientEnd = Color(0xFF303F9F);
  static const Color darkLoginButtonBackground = Color(0xFF303F9F);
  static const Color darkLoginButtonText = white;
  static const Color darkLoginCardBackground = Color(0xFF1E1E1E);

  // Dark Mode Dialog Colors
  static const Color darkDialogBackground = darkSurface;
  static const Color darkDialogBorder = darkPrimary;
  static const Color darkSectionItemBackground = Color(0xFF282828);

  // Filter Colors - Light Mode
  static const Color filterAllLight = Color(0xFF2196F3); // Blue
  static const Color filterWithSectionsLight = Color(0xFF4CAF50); // Green
  static const Color filterWithoutSectionsLight = Color(0xFFF44336); // Red

  // Filter Colors - Dark Mode
  static const Color filterAllDark = Color(0xFF90CAF9); // Light Blue
  static const Color filterWithSectionsDark = Color(0xFF81C784); // Light Green
  static const Color filterWithoutSectionsDark = Color(0xFFE57373); // Light Red

  // Navigation and Error Colors
  static const Color navigationIconColor = Color(0xFFFFFFFF);
  static const Color errorText = Color(0xFFD32F2F);

  // Menu Button Colors - Light Mode
  static const Color courseSelectionStartColor = Color(0xFF1976D2); // Blue
  static const Color courseSelectionEndColor = Color(0xFF64B5F6);

  static const Color scheduleStartColor = Color(0xFF4CAF50); // Green
  static const Color scheduleEndColor = Color(0xFF81C784);

  static const Color gradesStartColor = Color(0xFF9C27B0); // Purple
  static const Color gradesEndColor = Color(0xFFBA68C8);

  static const Color messagesStartColor = Color(0xFFF57C00); // Orange
  static const Color messagesEndColor = Color(0xFFFFB74D);

  static const Color nextTermStartColor = Color(0xFF00796B); // Teal
  static const Color nextTermEndColor = Color(0xFF4DB6AC);

  // Menu Button Colors - Dark Mode
  static const Color darkCourseSelectionStartColor = Color(0xFF0D47A1);
  static const Color darkCourseSelectionEndColor = Color(0xFF42A5F5);

  static const Color darkScheduleStartColor = Color(0xFF1B5E20);
  static const Color darkScheduleEndColor = Color(0xFF66BB6A);

  static const Color darkGradesStartColor = Color(0xFF4A148C);
  static const Color darkGradesEndColor = Color(0xFF9575CD);

  static const Color darkMessagesStartColor = Color(0xFFE65100);
  static const Color darkMessagesEndColor = Color(0xFFFFB74D);

  static const Color darkNextTermStartColor = Color(0xFF004D40);
  static const Color darkNextTermEndColor = Color(0xFF26A69A);

  // Dormitory Specific Colors - Light Mode
  static const Color primary = Color(0xFF1976D2);
  static const Color appBarBackground = primary;
  static const Color floorCardBorder = primary;
  static const Color blockBorder = primary;

  // Dormitory Specific Colors - Dark Mode
  static const Color darkPrimary = Color(0xFF2196F3);
  static const Color darkFloorCardBorder = Color(0xFF3D3D3D);
  static const Color darkBlockBorder = Color(0xFF3D3D3D);
}
