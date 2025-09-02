import 'package:flutter/material.dart';
import '../../../core/style/text_styles.dart';
import '../../../core/theme/dark_mode_controller.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final DarkModeController darkMode;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.darkMode,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(
              color:
                  darkMode.isDarkMode ? Colors.blue[300]! : Colors.blue[700]!,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor:
                darkMode.isDarkMode ? Colors.blue[700] : Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );

    final child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined
                    ? (darkMode.isDarkMode
                        ? Colors.blue[300]!
                        : Colors.blue[700]!)
                    : Colors.white,
              ),
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTextStyles.body(darkMode.isDarkMode).copyWith(
                  color: isOutlined
                      ? (darkMode.isDarkMode
                          ? Colors.blue[300]
                          : Colors.blue[700])
                      : Colors.white,
                ),
              ),
            ],
          );

    return SizedBox(
      height: 48,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
