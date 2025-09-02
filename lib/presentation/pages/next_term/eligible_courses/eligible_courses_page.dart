import 'package:flutter/material.dart';
import '../../../../../data/services/hive_service.dart';
import 'section_popup.dart';
import '../../../../../core/style/colors.dart';
import '../../../../../core/style/text_styles.dart';
import '../../../../../core/style/sizes.dart';
import '../../../../../core/theme/dark_mode_controller.dart';

import '../../../../../shared/widgets/dark_mode_toggle.dart';

class EligibleCoursesPage extends StatefulWidget {
  final List<int> selectedCourseIds;
  final List<Map<String, dynamic>>? cachedCourses;
  final Map<int, bool>? courseSections;
  final HiveService hiveService;

  const EligibleCoursesPage({
    Key? key,
    required this.selectedCourseIds,
    this.cachedCourses,
    this.courseSections,
    required this.hiveService,
  }) : super(key: key);

  @override
  _EligibleCoursesPageState createState() => _EligibleCoursesPageState();
}

class _EligibleCoursesPageState extends State<EligibleCoursesPage> {
  List<Map<String, dynamic>>? _eligibleCourses;
  late final DarkModeController darkMode;
  String filterOption = 'all';
  bool _isLoading = true;

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    darkMode = DarkModeController();
    darkMode.addListener(_onThemeChanged);
    _loadCourses();
  }

  @override
  void dispose() {
    darkMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      print('بارگذاری مجدد اطلاعات از کش...');
      final allData = await widget.hiveService.getAllData();

      if (allData.containsKey('course_map')) {
        final courseMap = allData['course_map'] as Map<String, dynamic>;

        // فقط از سکشن‌های جداگانه استفاده می‌کنیم
        final allSections = allData['sections'] as List<dynamic>? ?? [];
        final sectionsByCourse = <int, List<Map<String, dynamic>>>{};

        // گروه‌بندی سکشن‌ها بر اساس course_id
        for (final section in allSections) {
          final courseId = section['course_id'] as int;
          sectionsByCourse.putIfAbsent(courseId, () => []);
          sectionsByCourse[courseId]!.add(Map<String, dynamic>.from(section));
        }

        final courses = courseMap.values.map((course) {
          final courseData = Map<String, dynamic>.from(
              course['course'] as Map<String, dynamic>);
          final courseId = courseData['id'] as int;

          // استفاده از سکشن‌های جداگانه به جای سکشن‌های درون course
          courseData['sections'] = sectionsByCourse[courseId] ?? [];

          return courseData;
        }).toList();

        setState(() {
          _eligibleCourses = courses
              .where(
                  (course) => widget.selectedCourseIds.contains(course['id']))
              .toList();
          print('تعداد دروس بارگذاری شده: ${_eligibleCourses!.length}');
        });
      }
    } catch (e) {
      print('Error loading course data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری دروس: لطفاً دوباره تلاش کنید'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _eligibleCourses = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مدیریت سکشن‌های دروس انتخابی',
          style: TextStyle(
            color:
                darkMode.isDarkMode ? AppColors.darkText : AppColors.appBarText,
          ),
        ),
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkAppBarBackground
            : AppColors.appBarBackground,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: filterOption == 'all'
                  ? (darkMode.isDarkMode
                      ? AppColors.filterAllDark
                      : AppColors.filterAllLight)
                  : filterOption == 'withSections'
                      ? (darkMode.isDarkMode
                          ? AppColors.filterWithSectionsDark
                          : AppColors.filterWithSectionsLight)
                      : (darkMode.isDarkMode
                          ? AppColors.filterWithoutSectionsDark
                          : AppColors.filterWithoutSectionsLight),
            ),
            onPressed: () {
              setState(() {
                if (filterOption == 'all') {
                  filterOption = 'withSections';
                } else if (filterOption == 'withSections') {
                  filterOption = 'withoutSections';
                } else {
                  filterOption = 'all';
                }
              });
            },
          ),
          DarkModeToggle(controller: darkMode),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCoursesList(),
    );
  }

  Widget _buildCoursesList() {
    if (_eligibleCourses == null || _eligibleCourses!.isEmpty) {
      return const Center(child: Text('هیچ درسی پیدا نشد.'));
    }

    return ListView.builder(
      itemCount: _eligibleCourses!.length,
      itemBuilder: (context, index) {
        final course = _eligibleCourses![index];
        final courseId = course['id'];
        final courseName =
            course['name'] ?? course['course_name'] ?? 'درس ناشناخته';

        // بررسی وجود سکشن بر اساس لیست سکشن‌های درس
        final sections = course['sections'] as List<dynamic>;
        final hasSection = sections.isNotEmpty;

        if ((filterOption == 'withSections' && !hasSection) ||
            (filterOption == 'withoutSections' && hasSection)) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: AppSizes.cardMargin,
          padding: AppSizes.cardPadding,
          decoration: BoxDecoration(
            color: darkMode.isDarkMode
                ? AppColors.darkCardBackground
                : AppColors.white,
            borderRadius: AppSizes.defaultRadius,
            boxShadow: [
              BoxShadow(
                color: darkMode.isDarkMode ? Colors.black26 : Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: darkMode.isDarkMode
                ? Border.all(
                    color: AppColors.darkDivider,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                courseName,
                style: AppTextStyles.courseRegistrationTitle.copyWith(
                  color:
                      darkMode.isDarkMode ? AppColors.darkText : Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: darkMode.isDarkMode
                      ? AppColors.darkAccent
                      : AppColors.blue,
                ),
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => SectionPopup(
                      courseId: courseId,
                      courseName: courseName,
                      hiveService: widget.hiveService,
                    ),
                  );

                  // اگر تغییری در سکشن‌ها ایجاد شده باشد
                  if (result == true) {
                    // دریافت اطلاعات جدید
                    setState(() => _isLoading = true);
                    try {
                      // از همان متد _loadCourses استفاده می‌کنیم که منطق صحیح بارگذاری را دارد
                      await _loadCourses();
                    } catch (e) {
                      print('Error refreshing course data: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'خطا در بروزرسانی اطلاعات: لطفاً دوباره تلاش کنید'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
