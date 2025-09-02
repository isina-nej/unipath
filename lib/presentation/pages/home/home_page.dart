import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../widgets/animated_menu_button.dart';
import '../../../core/style/sizes.dart';
import '../../../core/style/text_styles.dart';
import '../../../../core/theme/dark_mode_controller.dart';
import '../../../core/routing/app_routes.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/hive_service.dart';
import '../../../core/utils/error_handler.dart';

/// صفحه اصلی برنامه
/// این کلاس از الگوی State Management استفاده می‌کند و ریسپانسیو است
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
    _loadInitialData();
  }

  /// بارگذاری داده‌های اولیه
  Future<void> _loadInitialData() async {
    await _checkAndLoadData();
    await _debugPrintCourses();
  }

  /// نمایش اطلاعات کش برای دیباگ
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

  /// بررسی و بارگذاری داده‌ها
  Future<void> _checkAndLoadData() async {
    final lastUpdateTime = await widget.hiveService.getLastUpdateTime();
    if (lastUpdateTime == null ||
        DateTime.now().difference(lastUpdateTime).inHours >= 24) {
      await _refreshData();
    }
  }

  /// به‌روزرسانی داده‌ها
  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final allData = await ApiService.getAllUniversityData();
      await widget.hiveService.saveServerData(allData);

      if (mounted) {
        _showSnackBar('اطلاعات با موفقیت به‌روزرسانی شد', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('خطا در به‌روزرسانی اطلاعات', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  /// نمایش SnackBar
  void _showSnackBar(String message, Color color) {
    if (color == Colors.green) {
      ErrorHandler.showSuccessSnackBar(context, message);
    } else {
      ErrorHandler.showErrorSnackBar(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => _buildMobileLayout(),
      tablet: (context) => _buildTabletLayout(),
      desktop: (context) => _buildDesktopLayout(),
    );
  }

  /// ساخت لایه موبایل
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(crossAxisCount: 2),
    );
  }

  /// ساخت لایه تبلت
  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(crossAxisCount: 3),
    );
  }

  /// ساخت لایه دسکتاپ
  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(crossAxisCount: 4),
    );
  }

  /// ساخت AppBar
  PreferredSizeWidget _buildAppBar() {
    final darkMode = DarkModeController.shared;
    final isDark = darkMode.isDarkMode;

    return AppBar(
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
      actions: [
        IconButton(
          icon: Icon(
            Icons.account_circle,
            size: 30,
            color: isDark ? Colors.white : Colors.black,
          ),
          tooltip: 'پروفایل',
          onPressed: () => _showProfileDialog(),
        ),
      ],
    );
  }

  /// نمایش دیالوگ پروفایل
  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پروفایل'),
        content: const Text('این بخش در حال توسعه است'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  /// ساخت بدنه صفحه
  Widget _buildBody({required int crossAxisCount}) {
    final darkMode = DarkModeController.shared;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        padding: AppSizes.pagePadding,
        mainAxisSpacing: AppSizes.gridSpacing,
        crossAxisSpacing: AppSizes.gridSpacing,
        childAspectRatio: 1.0,
        children: _buildMenuButtons(darkMode),
      ),
    );
  }

  /// ساخت دکمه‌های منو
  List<Widget> _buildMenuButtons(DarkModeController darkMode) {
    return [
      _buildMenuButton(
        title: 'انتخاب واحد',
        icon: Icons.school,
        onTap: () => AppRoutes.goToCourse(),
        startColor: darkMode.getMenuButtonStartColor('courseSelection'),
        endColor: darkMode.getMenuButtonEndColor('courseSelection'),
      ),
      _buildMenuButton(
        title: 'برنامه کلاسی',
        icon: Icons.calendar_today,
        onTap: () => AppRoutes.goToSchedule(),
        startColor: darkMode.getMenuButtonStartColor('schedule'),
        endColor: darkMode.getMenuButtonEndColor('schedule'),
      ),
      _buildMenuButton(
        title: 'افزودن سکشن',
        icon: Icons.add_box,
        onTap: () => AppRoutes.goToCourseRegistration(),
        startColor: darkMode.getMenuButtonStartColor('sectionAdd'),
        endColor: darkMode.getMenuButtonEndColor('sectionAdd'),
      ),
      _buildMenuButton(
        title: 'زمان‌بندی دروس',
        icon: Icons.schedule,
        onTap: () => AppRoutes.goToSchedule(),
        startColor: darkMode.getMenuButtonStartColor('timetable'),
        endColor: darkMode.getMenuButtonEndColor('timetable'),
      ),
    ];
  }

  /// ساخت یک دکمه منو
  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color startColor,
    required Color endColor,
  }) {
    return AnimatedMenuButton(
      title: title,
      style: AppTextStyles.mainPageMenuButton(
          DarkModeController.shared.isDarkMode),
      icon: icon,
      onTap: onTap,
      gradientStartColor: startColor,
      gradientEndColor: endColor,
    );
  }
}
