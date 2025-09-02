import 'package:flutter/material.dart';
import '../../core/style/colors.dart';
import '../../core/style/sizes.dart';
import '../../core/theme/dark_mode_controller.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final DarkModeController darkMode;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomCard({
    super.key,
    required this.child,
    required this.darkMode,
    this.onTap,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? AppSizes.cardMargin,
      color: backgroundColor ??
          (darkMode.isDarkMode
              ? AppColors.darkFloorCardBackground
              : AppColors.floorCardBackground),
      elevation: darkMode.isDarkMode ? 0 : AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppSizes.defaultRadius,
        side: BorderSide(
          color: borderColor ??
              (darkMode.isDarkMode
                  ? AppColors.darkFloorCardBorder
                  : AppColors.floorCardBorder),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSizes.defaultRadius,
          onTap: onTap,
          child: Padding(
            padding: AppSizes.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}
