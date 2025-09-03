import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'core/theme/dark_mode_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_routes.dart';
import 'data/models/course_model.dart';
import 'data/models/section_model.dart';
import 'data/models/section_time_model.dart';
import 'data/services/hive_service.dart';
import 'controllers/auth_controller.dart';

/// کلاس اصلی برنامه
/// این کلاس مسئولیت راه‌اندازی برنامه و تنظیمات اولیه را بر عهده دارد
class UniPathApp {
  // Private constructor
  UniPathApp._();

  // نمونه Singleton
  static final UniPathApp _instance = UniPathApp._();
  static UniPathApp get instance => _instance;

  /// متد راه‌اندازی برنامه
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // راه‌اندازی Hive
    await _initializeHive();

    // راه‌اندازی سرویس‌ها
    await _initializeServices();
  }

  /// راه‌اندازی Hive
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();

    // پاک کردن کش باکس‌ها برای رفع مشکل نوع (فقط یک بار)
    await Hive.deleteBoxFromDisk('courses');
    await Hive.deleteBoxFromDisk('sections');

    // ثبت Hive Adapters
    Hive.registerAdapter(CourseModelAdapter());
    Hive.registerAdapter(SectionModelAdapter());
    Hive.registerAdapter(SectionTimeModelAdapter());

    // باز کردن باکس‌ها
    await Hive.openBox('courses');
    await Hive.openBox('sections');
    await Hive.openBox('lastUpdate');
  }

  /// راه‌اندازی سرویس‌ها
  static Future<void> _initializeServices() async {
    final hiveService = HiveService();
    await hiveService.init();

    final darkModeController = DarkModeController();
    await darkModeController.init();

    // Initialize auth controller
    Get.put(AuthController());

    // اجرای برنامه
    runApp(MyApp(
      darkModeController: darkModeController,
      hiveService: hiveService,
    ));
  }
}

/// ویجت اصلی برنامه
class MyApp extends StatelessWidget {
  final DarkModeController darkModeController;
  final HiveService hiveService;

  const MyApp({
    super.key,
    required this.darkModeController,
    required this.hiveService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkModeController,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'UniPath',
          locale: AppLocalizations.supportedLocales.first,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.delegates,
          theme: AppTheme.getTheme(darkModeController.themeData.colorScheme),
          initialRoute: AppRoutes.login,
          getPages: AppRoutes.getPages(hiveService),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          // تنظیمات انتقال زیبا
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 500),
          defaultGlobalState: true,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
        );
      },
    );
  }
}

/// نقطه ورود برنامه
void main() async {
  await UniPathApp.initialize();
}
