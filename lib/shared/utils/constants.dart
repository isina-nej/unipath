/// Collection of constant values used throughout the app
class AppConstants {
  // API Constants
  static const String baseUrl = 'https://isinanej.pythonanywhere.com';
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;

  // Hive Box Names
  static const String coursesBox = 'courses';
  static const String sectionsBox = 'sections';
  static const String lastUpdateBox = 'last_update';

  // Route Names
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';

  // Asset Paths
  static const String logoPath = 'assets/logo/logo.PNG';

  // Colors Names (for consistency)
  static const String primaryColorName = 'primary';
  static const String accentColorName = 'accent';
  static const String backgroundColorName = 'background';

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 8.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'خطا در برقراری ارتباط با سرور';
  static const String timeoutMessage = 'زمان درخواست به پایان رسید';
  static const String generalErrorMessage = 'خطایی رخ داده است';

  // Success Messages
  static const String saveSuccessMessage = 'اطلاعات با موفقیت ذخیره شد';
  static const String updateSuccessMessage = 'اطلاعات با موفقیت به‌روزرسانی شد';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;

  // Cache Duration
  static const Duration cacheDuration = Duration(days: 1);

  // Academic Constants
  static const int minUnitsPerTerm = 12;
  static const int maxUnitsPerTerm = 20;
  static const int defaultUnitsPerTerm = 16;

  static const int passingGrade = 10;
  static const double maxGPA = 20.0;

  // Course Types
  static const String mandatoryCourse = 'mandatory';
  static const String optionalCourse = 'optional';
  static const String generalCourse = 'general';
  static const String specializedCourse = 'specialized';

  // Academic Calendar
  static const String fallSemester = 'نیمسال اول';
  static const String springSemester = 'نیمسال دوم';
  static const String summerSemester = 'ترم تابستان';

  // Dormitory Constants
  static const int maxRoomCapacity = 4;
  static const int minRoomNumber = 100;
  static const int maxRoomNumber = 999;

  static const Map<String, String> roomTypes = {
    'single': 'تک نفره',
    'double': 'دو نفره',
    'triple': 'سه نفره',
    'quad': 'چهار نفره',
  };

  static const Map<String, String> facilityTypes = {
    'bathroom': 'سرویس بهداشتی',
    'kitchen': 'آشپزخانه',
    'laundry': 'رختشویخانه',
    'study': 'اتاق مطالعه',
    'gym': 'سالن ورزشی',
  };

  // Time Slots (for course scheduling)
  static const List<String> timeSlots = [
    '8:00-10:00',
    '10:00-12:00',
    '14:00-16:00',
    '16:00-18:00',
  ];

  // Week Days
  static const Map<String, String> weekDays = {
    'saturday': 'شنبه',
    'sunday': 'یکشنبه',
    'monday': 'دوشنبه',
    'tuesday': 'سه‌شنبه',
    'wednesday': 'چهارشنبه',
    'thursday': 'پنجشنبه',
  };
}
