import 'package:flutter/material.dart';
import '../../../core/style/text_styles.dart';
import '../../../core/theme/dark_mode_controller.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DarkModeController darkMode;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.darkMode,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextStyles.body(darkMode.isDarkMode),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption(darkMode.isDarkMode),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: darkMode.isDarkMode ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: darkMode.isDarkMode ? Colors.blue[300]! : Colors.blue[700]!,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: darkMode.isDarkMode ? Colors.red[300]! : Colors.red[700]!,
          ),
        ),
      ),
    );
  }
}
