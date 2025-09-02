import 'package:flutter/material.dart';
import '../../../../core/style/colors.dart';
import '../../../../core/theme/dark_mode_controller.dart';
import '../../../../../shared/widgets/dark_mode_toggle.dart';
import '../../../../../data/services/hive_service.dart';

class CourseTimetablePage extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final HiveService hiveService;
  final int courseId; // Keep for backwards compatibility

  const CourseTimetablePage({
    Key? key,
    required this.courses,
    required this.hiveService,
    required this.courseId,
  }) : super(key: key);

  @override
  State<CourseTimetablePage> createState() => _CourseTimetablePageState();
}

class _CourseTimetablePageState extends State<CourseTimetablePage> {
  late final DarkModeController darkMode;
  final List<String> days = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه'];
  final List<int> hours = List.generate(13, (index) => index + 8); // 8 تا 20
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    darkMode = DarkModeController();

    _isLoading = true;
    _sections = widget.courses.expand<Map<String, dynamic>>((course) {
      final sections = course['sections'] as List<dynamic>? ?? [];
      return sections.map((section) {
        final rawTimes = section['times'];
        List<Map<String, dynamic>> formattedTimes = [];

        if (rawTimes is List) {
          formattedTimes = rawTimes
              .whereType<Map<String, dynamic>>()
              .map((time) => {
                    'day': time['day'],
                    'start': time['start_time'] ?? time['start'],
                    'end': time['end_time'] ?? time['end'],
                    'room': time['location'] ?? time['room'] ?? 'نامشخص',
                  })
              .toList();
        }

        return {
          ...section,
          'course_name': course['course_name'] ??
              'نامشخص', // Get course name from course object
          'times': formattedTimes,
          'section_number': section['section_number'] ?? '',
          'instructor_name': section['instructor_name'] ?? 'نامشخص',
        };
      });
    }).toList();
    _isLoading = false;

    // Debug log
    print('سکشن‌های دریافتی برای جدول زمانی:');
    for (final section in _sections) {
      print(section);
    }
    setState(() {});
  }

  Widget _buildTimeCell(BuildContext context, int hour) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: darkMode.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,
      child: Text(
        '$hour:00',
        style: TextStyle(
          color: darkMode.isDarkMode ? AppColors.darkText : AppColors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String day) {
    return Container(
      decoration: BoxDecoration(
        color: darkMode.isDarkMode
            ? AppColors.darkCardBackground
            : AppColors.blueShade100,
        border: Border.all(
          color: darkMode.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          color: darkMode.isDarkMode ? AppColors.darkText : AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeSlotCell(int hour, int dayIndex) {
    // پیدا کردن همه درس‌های این ساعت
    final sectionsForSlot = _sections.where((section) {
      final times = section['times'] as List<dynamic>;
      return times.any((time) {
        final timeDay = time['day'];
        final timeStart = time['start'];
        final timeEnd = time['end'];

        int dayIdx = timeDay is int
            ? timeDay
            : (timeDay is String ? days.indexOf(timeDay) : -1);
        int start = timeStart is int
            ? timeStart
            : (timeStart is String
                ? int.tryParse(timeStart.split(':').first) ?? -1
                : -1);
        int end = timeEnd is int
            ? timeEnd
            : (timeEnd is String
                ? int.tryParse(timeEnd.split(':').first) ?? -1
                : -1);

        return dayIdx == dayIndex && start <= hour && hour < end;
      });
    }).toList();

    if (sectionsForSlot.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: darkMode.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
      );
    }

    // نمایش همه درس‌ها با Wrap
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: darkMode.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      margin: const EdgeInsets.all(1.0),
      padding: const EdgeInsets.all(4.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: sectionsForSlot.map((section) {
          return Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color:
                  darkMode.isDarkMode ? AppColors.darkAccent : AppColors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  section['course_name'] ?? '',
                  style: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  section['instructor_name'] ?? '',
                  style: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : AppColors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkAppBarBackground
            : AppColors.indigo,
        title: const Text(
          'برنامه زمانی دروس',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          DarkModeToggle(controller: darkMode),
        ],
      ),
      body: Container(
        color: darkMode.isDarkMode
            ? AppColors.darkBackground
            : AppColors.blueShade50,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _sections.isEmpty
                ? const Center(child: Text('هیچ سکشنی یافت نشد'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            children: [
                              // Empty corner cell
                              Container(
                                width: 60,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: darkMode.isDarkMode
                                      ? AppColors.darkCardBackground
                                      : AppColors.blueShade100,
                                  border: Border.all(
                                    color: darkMode.isDarkMode
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                              ),
                              // Day headers
                              ...days.map((day) => SizedBox(
                                    width: 120,
                                    child: _buildHeaderCell(day),
                                  )),
                            ],
                          ),
                          // Time slots
                          ...hours.map((hour) => Row(
                                children: [
                                  // Time cell
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: _buildTimeCell(context, hour),
                                  ),
                                  // Day cells
                                  ...List.generate(
                                    days.length,
                                    (dayIndex) => SizedBox(
                                      width: 120,
                                      height: 60,
                                      child: _buildTimeSlotCell(hour, dayIndex),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
