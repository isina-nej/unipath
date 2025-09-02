import 'package:flutter/material.dart';
import '../../core/theme/dark_mode_controller.dart';

class LoadingIndicator extends StatelessWidget {
  final DarkModeController darkMode;
  final double size;

  const LoadingIndicator({
    super.key,
    required this.darkMode,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            darkMode.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
