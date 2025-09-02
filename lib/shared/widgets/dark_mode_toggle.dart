import 'package:flutter/material.dart';
import '../../core/theme/dark_mode_controller.dart';

class DarkModeToggle extends StatelessWidget {
  final DarkModeController controller;

  const DarkModeToggle({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      onPressed: () {
        controller.toggleDarkMode();
      },
      tooltip: controller.isDarkMode ? 'روشن' : 'تاریک',
    );
  }
}
