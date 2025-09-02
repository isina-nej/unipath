import 'package:flutter/material.dart';
import '../../core/style/colors.dart';
import '../../core/style/sizes.dart';
import '../../core/style/text_styles.dart';
import '../../core/theme/dark_mode_controller.dart';

class AnimatedMenuButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final TextStyle? style;
  final String? semanticsLabel;

  const AnimatedMenuButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.gradientStartColor,
    this.gradientEndColor,
    this.style,
    this.semanticsLabel,
  });

  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeController();
    final isDark = darkMode.isDarkMode;

    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? widget.title,
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            elevation: _isHovered
                ? AppSizes.cardElevation * 1.5
                : AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.defaultRadius,
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: AppSizes.defaultRadius,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppSizes.defaultRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.gradientStartColor ??
                          (isDark
                              ? AppColors.darkPrimary
                              : Colors.blue[300] ?? Colors.blue),
                      widget.gradientEndColor ??
                          (isDark
                              ? AppColors.darkAccent
                              : Colors.blue[600] ?? Colors.blue),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: 40,
                      color: isDark ? AppColors.darkIcon : Colors.white,
                      semanticLabel: widget.semanticsLabel,
                    ),
                    SizedBox(height: AppSizes.defaultPadding),
                    Text(
                      widget.title,
                      style: widget.style ??
                          AppTextStyles.mainPageMenuButton(isDark),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
