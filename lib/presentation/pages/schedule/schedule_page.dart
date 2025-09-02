import 'package:flutter/material.dart';
import '../../../core/style/text_styles.dart';
import '../../../core/style/colors.dart';
import '../../../data/services/hive_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/dark_mode_toggle.dart';
import '../../../core/theme/dark_mode_controller.dart' as theme;

class SchedulePage extends StatelessWidget {
  final HiveService hiveService;

  const SchedulePage({
    super.key,
    required this.hiveService,
  });

  @override
  Widget build(BuildContext context) {
    final darkMode = theme.DarkModeController.shared;

    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            'برنامه کلاسی',
            style: AppTextStyles.getPageTitle(darkMode.isDarkMode),
          ),
          centerTitle: true,
          backgroundColor: darkMode.isDarkMode
              ? AppColors.darkAppBarBackground
              : AppColors.appBarBackground,
          actions: [
            DarkModeToggle(controller: darkMode),
          ],
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          color: darkMode.isDarkMode
              ? AppColors.darkScheduleBackground
              : AppColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: darkMode.isDarkMode
                    ? AppColors.darkIconInactive
                    : Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'برنامه هفتگی',
                style: AppTextStyles.schedulePageTitle(darkMode.isDarkMode),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'برای مشاهده برنامه کلاسی خود\nابتدا دروس خود را انتخاب کنید',
                style: AppTextStyles.cardCaption(darkMode.isDarkMode),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: CustomButton(
                  text: 'انتخاب دروس',
                  darkMode: darkMode,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icons.add_circle_outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
