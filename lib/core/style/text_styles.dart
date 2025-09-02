import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Common styles
  static TextStyle getPageTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? AppColors.darkText : AppColors.black,
    );
  }

  static TextStyle body(bool isDarkMode) {
    return TextStyle(
      fontSize: 14,
      color: isDarkMode ? AppColors.darkText : AppColors.black87,
    );
  }

  static TextStyle caption(bool isDarkMode) {
    return TextStyle(
      fontSize: 12,
      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.black54,
    );
  }

  static TextStyle mainPageMenuButton(bool isDarkMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: isDarkMode ? AppColors.darkText : AppColors.white,
    );
  }

  static TextStyle schedulePageTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? AppColors.darkText : AppColors.black,
    );
  }

  static TextStyle errorText(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode ? AppColors.darkError : AppColors.errorText,
      fontSize: 14,
    );
  }

  // Course selection styles
  static const TextStyle courseRegistrationTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionPopupTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionPopupListTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionPopupListSubtitle = TextStyle(
    fontSize: 12,
  );

  static const TextStyle sectionPopupEmpty = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.italic,
  );

  static TextStyle blockTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDarkMode ? AppColors.darkText : AppColors.black,
    );
  }

  static TextStyle blockName(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDarkMode ? AppColors.darkText : AppColors.black87,
    );
  }

  static TextStyle floorTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDarkMode ? AppColors.darkText : AppColors.black,
    );
  }

  // Login styles
  static TextStyle getLoginTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? AppColors.darkText : AppColors.black87,
    );
  }

  static TextStyle getLoginButtonText(bool isDarkMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDarkMode
          ? AppColors.darkLoginButtonText
          : AppColors.loginButtonText,
    );
  }

  // Section styles
  static TextStyle eligibleCourseTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDarkMode ? AppColors.darkText : AppColors.black87,
    );
  }

  static TextStyle eligibleCourseSubtitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 14,
      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.black54,
    );
  }

  // Card text styles
  static TextStyle cardTitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDarkMode ? AppColors.darkText : AppColors.black87,
    );
  }

  static TextStyle cardSubtitle(bool isDarkMode) {
    return TextStyle(
      fontSize: 14,
      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.black54,
    );
  }

  static TextStyle cardCaption(bool isDarkMode) {
    return TextStyle(
      fontSize: 12,
      color: isDarkMode
          ? AppColors.darkTextSecondary.withValues(alpha: 0.8 * 255)
          : AppColors.black54.withValues(alpha: 0.8 * 255),
    );
  }
}
