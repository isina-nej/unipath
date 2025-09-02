import 'package:flutter/material.dart';
import '../../core/style/colors.dart';
import '../../core/style/text_styles.dart';
import '../../core/theme/dark_mode_controller.dart';
import 'dark_mode_toggle.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final DarkModeController darkMode;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.darkMode,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.blockTitle(darkMode.isDarkMode),
      ),
      centerTitle: true,
      backgroundColor: darkMode.isDarkMode
          ? AppColors.darkAppBarBackground
          : AppColors.appBarBackground,
      actions: actions ?? [DarkModeToggle(controller: darkMode)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
