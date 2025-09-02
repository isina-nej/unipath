import 'package:flutter/material.dart';
import 'colors.dart';

class AppSizes {
  // AppBar sizes
  static const double appBarElevation = 0;

  // Padding & Margin sizes
  static const double defaultPadding = 16.0;
  static const EdgeInsets pagePadding = EdgeInsets.all(defaultPadding);
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: defaultPadding);
  static const EdgeInsets verticalPadding =
      EdgeInsets.symmetric(vertical: defaultPadding);

  // Card sizes
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardMargin = EdgeInsets.all(8.0);
  static const double cardElevation = 4.0;
  static final BorderRadius defaultRadius = BorderRadius.circular(12.0);
  static final BorderRadius dialogRadius = BorderRadius.circular(16.0);

  // Shadow configuration
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.blackWithOpacity10,
      blurRadius: 8.0,
      offset: const Offset(0, 4),
    ),
  ];

  // Dialog sizes
  static const double dialogMaxWidth = 400.0;
  static const double dialogMinWidth = 280.0;
  static const double dialogMinHeight = 200.0;

  // Grid layout sizes
  static const int webCrossAxisCount = 4;
  static const int mobileCrossAxisCount = 2;
  static const double gridSpacing = 16.0;
}
