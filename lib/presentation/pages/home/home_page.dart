import 'package:flutter/material.dart';
import '../../widgets/animated_menu_button.dart';
import '../../../core/style/sizes.dart';
import '../../../core/style/text_styles.dart';
import '../../../../core/theme/dark_mode_controller.dart';
import '../../../core/routing/app_routes.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/hive_service.dart';

class MainPage extends StatefulWidget {
  final HiveService hiveService;

  const MainPage({
    super.key,
    required this.hiveService,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _checkAndLoadData().then((_) => _debugPrintCourses());
  }

  Future<void> _debugPrintCourses() async {
    print('\n=== وضعیت داده‌های ذخیره شده در کش ===');
    try {
      final data = await widget.hiveService.getAllData();
      final courseMap = (data['course_map'] as Map?)?.length ?? 0;
      final sections = (data['sections'] as List?)?.length ?? 0;
      print('تعداد کل دروس در course_map: $courseMap');
      print('تعداد سکشن‌ها: $sections');
      print('=== پایان وضعیت داده‌ها ===\n');
    } catch (e) {
      print('خطا در نمایش اطلاعات کش: $e');
    }
  }

  Future<void> _checkAndLoadData() async {
    final lastUpdateTime = await widget.hiveService.getLastUpdateTime();
    if (lastUpdateTime == null ||
        DateTime.now().difference(lastUpdateTime).inHours >= 24) {
      await _refreshData();
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // دریافت همه اطلاعات با یک درخواست
      final allData = await ApiService.getAllUniversityData();

      // ذخیره مستقیم داده‌ها در Hive
      await widget.hiveService.saveServerData(allData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اطلاعات با موفقیت به‌روزرسانی شد'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در به‌روزرسانی اطلاعات'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeController.shared;
    final isDark = darkMode.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        // عنوان صفحه در وسط
        title: Text(
          'صفحه اصلی',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        leadingWidth: 100,

        // دکمه‌های سمت راست
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<int>(
              padding: const EdgeInsets.only(right: 4),
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black,
              ),
              tooltip: 'منو',
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      const Text('به‌روزرسانی اطلاعات'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 1) _refreshData();
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
              tooltip: isDark ? 'روشن' : 'تاریک',
              onPressed: () async {
                await darkMode.toggleDarkMode();
                setState(() {});
              },
            ),
          ],
        ),

        // دکمه‌های سمت چپ
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 30,
              color: isDark ? Colors.white : Colors.black,
            ),
            tooltip: 'پروفایل',
            onPressed: () {
              // TODO: نمایش صفحه پروفایل
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = MediaQuery.of(context).size.width > 600;
          final crossAxisCount = isWeb
              ? AppSizes.webCrossAxisCount
              : AppSizes.mobileCrossAxisCount;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              padding: AppSizes.pagePadding,
              mainAxisSpacing: AppSizes.gridSpacing,
              crossAxisSpacing: AppSizes.gridSpacing,
              childAspectRatio: 1.0,
              children: [
                AnimatedMenuButton(
                  title: 'انتخاب واحد',
                  style: AppTextStyles.mainPageMenuButton(
                      DarkModeController.shared.isDarkMode),
                  icon: Icons.school,
                  onTap: () {
                    AppRoutes.goToCourse();
                  },
                  gradientStartColor: DarkModeController()
                      .getMenuButtonStartColor('courseSelection'),
                  gradientEndColor: DarkModeController()
                      .getMenuButtonEndColor('courseSelection'),
                ),
                AnimatedMenuButton(
                  title: 'برنامه کلاسی',
                  style: AppTextStyles.mainPageMenuButton(
                      DarkModeController.shared.isDarkMode),
                  icon: Icons.calendar_today,
                  onTap: () {
                    AppRoutes.goToSchedule();
                  },
                  gradientStartColor:
                      DarkModeController().getMenuButtonStartColor('schedule'),
                  gradientEndColor:
                      DarkModeController().getMenuButtonEndColor('schedule'),
                ),
                AnimatedMenuButton(
                  title: 'افزودن سکشن',
                  style: AppTextStyles.mainPageMenuButton(
                      DarkModeController.shared.isDarkMode),
                  icon: Icons.add_box,
                  onTap: () {
                    AppRoutes.goToCourseRegistration();
                  },
                  gradientStartColor: DarkModeController()
                      .getMenuButtonStartColor('sectionAdd'),
                  gradientEndColor:
                      DarkModeController().getMenuButtonEndColor('sectionAdd'),
                ),
                AnimatedMenuButton(
                  title: 'زمان‌بندی دروس',
                  style: AppTextStyles.mainPageMenuButton(
                      DarkModeController.shared.isDarkMode),
                  icon: Icons.schedule,
                  onTap: () {
                    AppRoutes.goToSchedule();
                  },
                  gradientStartColor:
                      DarkModeController().getMenuButtonStartColor('timetable'),
                  gradientEndColor:
                      DarkModeController().getMenuButtonEndColor('timetable'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
