import 'package:get/get.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/course/course_page.dart';
import '../../presentation/pages/schedule/schedule_page.dart';
import '../../presentation/pages/next_term/course_registration_page.dart';
import '../../data/services/hive_service.dart';

/// کلاس مدیریت مسیرهای برنامه
/// این کلاس از الگوی Singleton استفاده می‌کند و تمامی مسیرها و ناوبری‌ها را مدیریت می‌کند
class AppRoutes {
  // Private constructor برای جلوگیری از نمونه‌سازی مستقیم
  AppRoutes._();

  // نمونه Singleton
  static final AppRoutes _instance = AppRoutes._();
  static AppRoutes get instance => _instance;

  // Route names - خصوصی برای جلوگیری از تغییر مستقیم
  static const String _home = '/';
  static const String _course = '/course';
  static const String _schedule = '/schedule';
  static const String _courseRegistration = '/next-term/registration';

  // Getters برای دسترسی به route names
  static String get home => _home;
  static String get course => _course;
  static String get schedule => _schedule;
  static String get courseRegistration => _courseRegistration;

  // Private method برای ایجاد صفحات
  static List<GetPage> _getPages(HiveService hiveService) {
    return [
      GetPage(
        name: _home,
        page: () => MainPage(hiveService: hiveService),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 500),
      ),
      GetPage(
        name: _course,
        page: () => CourseSelectionPage(hiveService: hiveService),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 400),
      ),
      GetPage(
        name: _schedule,
        page: () => SchedulePage(hiveService: hiveService),
        transition: Transition.upToDown,
        transitionDuration: const Duration(milliseconds: 500),
      ),
      GetPage(
        name: _courseRegistration,
        page: () => CourseRegistrationPage(hiveService: hiveService),
        transition: Transition.downToUp,
        transitionDuration: const Duration(milliseconds: 500),
      ),
    ];
  }

  // Public method برای دسترسی به صفحات
  static List<GetPage> getPages(HiveService hiveService) =>
      _getPages(hiveService);

  // Navigation methods با encapsulation بهتر
  static void goToHome() => Get.offAllNamed(_home);
  static void goToCourse() => Get.toNamed(_course);
  static void goToSchedule() => Get.toNamed(_schedule);
  static void goToCourseRegistration() => Get.toNamed(_courseRegistration);
  static void goBack() => Get.back();
}
