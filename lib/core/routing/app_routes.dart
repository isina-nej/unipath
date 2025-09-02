import 'package:get/get.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/course/course_page.dart';
import '../../presentation/pages/schedule/schedule_page.dart';
import '../../presentation/pages/next_term/course_registration_page.dart';
import '../../data/services/hive_service.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String course = '/course';
  static const String schedule = '/schedule';
  static const String courseRegistration = '/next-term/registration';

  // Get all pages
  static List<GetPage> getPages(HiveService hiveService) {
    return [
      GetPage(
        name: AppRoutes.home,
        page: () => MainPage(hiveService: hiveService),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 500),
      ),
      GetPage(
        name: AppRoutes.course,
        page: () => CourseSelectionPage(hiveService: hiveService),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 400),
      ),
      GetPage(
        name: AppRoutes.schedule,
        page: () => SchedulePage(hiveService: hiveService),
        transition: Transition.upToDown,
        transitionDuration: const Duration(milliseconds: 500),
      ),
      GetPage(
        name: AppRoutes.courseRegistration,
        page: () => CourseRegistrationPage(hiveService: hiveService),
        transition: Transition.downToUp,
        transitionDuration: const Duration(milliseconds: 500),
      ),
    ];
  }

  // Navigation methods with beautiful animations
  static void goToHome() {
    Get.offAllNamed(home);
  }

  static void goToCourse() {
    Get.toNamed(course);
  }

  static void goToSchedule() {
    Get.toNamed(schedule);
  }

  static void goToCourseRegistration() {
    Get.toNamed(courseRegistration);
  }

  // Back navigation
  static void goBack() {
    Get.back();
  }
}
