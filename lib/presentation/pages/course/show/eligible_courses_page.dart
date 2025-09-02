import 'package:flutter/material.dart';
import '../../../../../data/services/hive_service.dart';
import '../../../../../core/style/colors.dart';
import '../../../../../core/style/text_styles.dart';
import '../../../../../core/theme/dark_mode_controller.dart';
import 'course_timetable.dart';
import '../../../../../shared/widgets/dark_mode_toggle.dart';

class EligibleCoursesPage extends StatefulWidget {
  final List<int> selectedCourseIds;
  final HiveService hiveService;

  const EligibleCoursesPage({
    super.key,
    required this.selectedCourseIds,
    required this.hiveService,
  });

  @override
  State<EligibleCoursesPage> createState() => _EligibleCoursesPageState();
}

class _EligibleCoursesPageState extends State<EligibleCoursesPage> {
  List<Map<String, dynamic>>? _cachedCourses;
  Future<List<Map<String, dynamic>>>? _coursesFuture;
  final Map<int, bool> _coursesWithCorequisites = {};
  final Map<int, bool> _selectedEligibleCourses = {};
  late final DarkModeController darkMode;
  String filterOption =
      'all'; // Options: 'all', 'withSections', 'withoutSections'

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleCourseSelection(int courseId) {
    setState(() {
      _selectedEligibleCourses[courseId] =
          !(_selectedEligibleCourses[courseId] ?? false);
    });
  }

  @override
  void initState() {
    super.initState();
    darkMode = DarkModeController();
    darkMode.addListener(_onThemeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _coursesFuture = fetchEligibleCourses();
      });
    });
  }

  @override
  void dispose() {
    darkMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchEligibleCourses() async {
    if (_cachedCourses != null) {
      print('=== استفاده از داده‌های کش شده در حافظه ===');
      return _cachedCourses!;
    }

    try {
      print('\n=== شروع بارگذاری دروس مجاز ===');
      final data = await widget.hiveService.getAllData();
      print('داده‌های دریافتی از Hive:');
      print('کلیدهای موجود: ${data.keys.join(', ')}');

      final courseMap = data['course_map'] as Map<String, dynamic>?;
      final allSections = data['sections'] as List<dynamic>? ?? [];

      print('تعداد درس‌های موجود در کش: ${courseMap?.length ?? 0}');
      print('تعداد سکشن‌های موجود: ${allSections.length}');

      if (courseMap == null || courseMap.isEmpty) {
        print('هیچ درسی در کش یافت نشد');
        return [];
      }

      // گروه‌بندی سکشن‌ها بر اساس course_id
      final sectionsByCourse = <int, List<Map<String, dynamic>>>{};
      for (final section in allSections) {
        final courseId = section['course_id'] as int?;
        if (courseId != null) {
          sectionsByCourse.putIfAbsent(courseId, () => []);
          sectionsByCourse[courseId]!.add(Map<String, dynamic>.from(section));
        }
      }

      print('تعداد دروس با سکشن: ${sectionsByCourse.length}');
      List<Map<String, dynamic>> eligibleCourses = [];

      // محاسبه تعداد واحدهای باقی‌مانده
      int remainingUnits = 0;
      courseMap.values.forEach((courseData) {
        final course = courseData['course'] as Map<String, dynamic>?;
        if (course != null) {
          final courseId = course['id'] as int?;
          if (courseId != null &&
              !widget.selectedCourseIds.contains(courseId)) {
            final units =
                course['units'] as int? ?? course['number_unit'] as int? ?? 0;
            remainingUnits += units;
          }
        }
      });
      final ignorePrereq = remainingUnits <= 24;
      print('واحدهای باقی‌مانده: $remainingUnits');
      if (ignorePrereq)
        print('قانون ۲۴ واحد فعال شد: همه دروس باقی‌مانده مجاز هستند');

      for (final courseData in courseMap.values) {
        final course = courseData['course'] as Map<String, dynamic>?;
        if (course == null) continue;
        final courseId = course['id'] as int?;
        if (courseId == null || widget.selectedCourseIds.contains(courseId)) {
          continue;
        }
        if (ignorePrereq) {
          final sections = sectionsByCourse[courseId] ?? [];
          eligibleCourses.add({
            'id': courseId,
            'name': course['name'] ?? course['course_name'] ?? 'درس ناشناخته',
            'course_name':
                course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
            'units': course['units'] ?? course['number_unit'] ?? 0,
            'sections': sections,
          });
          continue;
        }

        // Check prerequisites
        bool allPrerequisitesMet = true;
        final prerequisites = courseData['prerequisites'] as List? ?? [];

        for (final prerequisite in prerequisites) {
          if (prerequisite is! Map<String, dynamic>) continue;

          for (int i = 1; i <= 3; i++) {
            final prerequisiteId = prerequisite['prerequisite_$i'] as int?;
            if (prerequisiteId != null &&
                !widget.selectedCourseIds.contains(prerequisiteId)) {
              allPrerequisitesMet = false;
              break;
            }
          }
          if (!allPrerequisitesMet) break;
        }

        if (allPrerequisitesMet) {
          // Check corequisites
          final corequisites = courseData['corequisites'] as List? ?? [];
          bool hasCorequisiteInSelection = false;
          bool allCorequisitesEligible = true;

          for (final corequisite in corequisites) {
            if (corequisite is! Map<String, dynamic>) continue;

            for (int i = 1; i <= 3; i++) {
              final corequisiteId = corequisite['corequisites_$i'] as int?;
              if (corequisiteId != null) {
                if (widget.selectedCourseIds.contains(corequisiteId)) {
                  hasCorequisiteInSelection = true;
                  break;
                } else {
                  // Check if corequisite's prerequisites are met
                  final corequisiteCourseData = courseMap.values.firstWhere(
                    (data) {
                      final courseData =
                          data['course'] as Map<String, dynamic>?;
                      return courseData != null &&
                          courseData['id'] == corequisiteId;
                    },
                    orElse: () => {},
                  );

                  if (corequisiteCourseData.isNotEmpty) {
                    final corequisitePrereqs =
                        corequisiteCourseData['prerequisites'] as List? ?? [];

                    for (final prereq in corequisitePrereqs) {
                      if (prereq is! Map<String, dynamic>) continue;

                      for (int j = 1; j <= 3; j++) {
                        final prereqId = prereq['prerequisite_$j'] as int?;
                        if (prereqId != null &&
                            !widget.selectedCourseIds.contains(prereqId)) {
                          allCorequisitesEligible = false;
                          break;
                        }
                      }
                      if (!allCorequisitesEligible) break;
                    }
                  } else {
                    allCorequisitesEligible = false;
                  }
                }
              }
              if (!allCorequisitesEligible) break;
            }
            if (!allCorequisitesEligible) break;
          }

          if (hasCorequisiteInSelection || allCorequisitesEligible) {
            _coursesWithCorequisites[courseId] = hasCorequisiteInSelection;

            // اضافه کردن سکشن‌های این درس
            final sections = sectionsByCourse[courseId] ?? [];

            eligibleCourses.add({
              'id': courseId,
              'name': course['name'] ?? course['course_name'] ?? 'درس ناشناخته',
              'course_name':
                  course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
              'units': course['units'] ?? course['number_unit'] ?? 0,
              'sections': sections, // <-- اضافه شد
            });
          }
        } else {
          // Add this block to ignore prerequisites for certain courses
          final ignorePrereq = false; // Change this condition as needed
          if (ignorePrereq) {
            final sections = sectionsByCourse[courseId] ?? [];
            eligibleCourses.add({
              'id': courseId,
              'name': course['name'] ?? course['course_name'] ?? 'درس ناشناخته',
              'course_name':
                  course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
              'units': course['units'] ?? course['number_unit'] ?? 0,
              'sections': sections,
            });
            continue;
          }
        }
      }

      print('تعداد دروس مجاز یافت شده: ${eligibleCourses.length}');
      _cachedCourses = eligibleCourses;
      return eligibleCourses;
    } catch (e) {
      print('خطا در بارگذاری دروس مجاز: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> filterCourses(String query) {
    if (query.isEmpty) {
      print('بازگشت تمام درس‌ها - فیلتر خالی');
      return List.from(_cachedCourses ?? []);
    }

    print('\n=== اعمال فیلتر جستجو: $query ===');
    final lowercaseQuery = query.toLowerCase();

    return (_cachedCourses ?? []).where((course) {
      final name = (course['name'] as String?)?.toLowerCase() ?? '';
      final code = (course['code'] as String?)?.toLowerCase() ?? '';

      // بررسی تطابق با نام یا کد درس
      final matches =
          name.contains(lowercaseQuery) || code.contains(lowercaseQuery);
      if (matches) {
        print('درس پیدا شد: ${course['name']} (${course['code']})');

        // نمایش اطلاعات سکشن‌ها برای درس پیدا شده
        final sections = course['sections'] as List<dynamic>?;
        if (sections != null && sections.isNotEmpty) {
          print('تعداد سکشن‌های موجود: ${sections.length}');
          for (final section in sections) {
            print(
                'سکشن ${section['section_number']}: ${section['instructor']} - ظرفیت: ${section['capacity']}');
          }
        } else {
          print('هیچ سکشنی برای این درس یافت نشد');
        }
      }
      return matches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeController.shared;

    final termColors = darkMode.isDarkMode
        ? [
            AppColors.darkRedSelected,
            AppColors.darkBlueSelected,
            AppColors.darkGreenSelected,
            AppColors.darkCyanSelected,
            AppColors.darkOrangeSelected,
            AppColors.darkPurpleSelected,
            AppColors.darkTealSelected,
            AppColors.darkPinkSelected,
          ]
        : [
            AppColors.redShade100,
            AppColors.blueShade100,
            AppColors.greenShade100,
            AppColors.cyanShade100,
            AppColors.orangeShade100,
            AppColors.purpleShade100,
            AppColors.tealShade100,
            AppColors.pinkShade100,
          ];

    Color courseColor(bool isSelected, int termIndex) => isSelected
        ? (darkMode.isDarkMode ? AppColors.darkAccent : AppColors.blue)
        : termColors[termIndex % termColors.length];

    Color termHeaderColor(int termIndex) =>
        termColors[termIndex % termColors.length];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkAppBarBackground
            : AppColors.indigo,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: filterOption != 'all'
                  ? (darkMode.isDarkMode
                      ? AppColors.darkAccent
                      : AppColors.white)
                  : (darkMode.isDarkMode
                      ? AppColors.darkText
                      : AppColors.white),
            ),
            tooltip: 'فیلتر دروس',
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: filterOption == 'all'
                          ? (darkMode.isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.blue)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'همه دروس',
                      style: TextStyle(
                        color: filterOption == 'all'
                            ? (darkMode.isDarkMode
                                ? AppColors.darkAccent
                                : AppColors.blue)
                            : null,
                        fontWeight:
                            filterOption == 'all' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'withSections',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: filterOption == 'withSections'
                          ? (darkMode.isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.blue)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'دروس دارای سکشن',
                      style: TextStyle(
                        color: filterOption == 'withSections'
                            ? (darkMode.isDarkMode
                                ? AppColors.darkAccent
                                : AppColors.blue)
                            : null,
                        fontWeight: filterOption == 'withSections'
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'withoutSections',
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      color: filterOption == 'withoutSections'
                          ? (darkMode.isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.blue)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'دروس بدون سکشن',
                      style: TextStyle(
                        color: filterOption == 'withoutSections'
                            ? (darkMode.isDarkMode
                                ? AppColors.darkAccent
                                : AppColors.blue)
                            : null,
                        fontWeight: filterOption == 'withoutSections'
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              setState(() {
                filterOption = value;
              });
            },
          ),
          DarkModeToggle(controller: darkMode),
        ],
        title: FutureBuilder<List<Map<String, dynamic>>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Text(
                'دروس مجاز',
                style: AppTextStyles.eligibleCourseTitle(darkMode.isDarkMode),
              );
            }

            final courses = snapshot.data!;
            int totalUnits = courses.fold(
                0, (sum, course) => sum + (course['units'] as int? ?? 0));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${courses.length} درس',
                  style: AppTextStyles.eligibleCourseTitle(darkMode.isDarkMode),
                ),
                Text(
                  '$totalUnits واحد',
                  style:
                      AppTextStyles.eligibleCourseSubtitle(darkMode.isDarkMode),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || _selectedEligibleCourses.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: FloatingActionButton.extended(
              onPressed: () {
                // گرفتن همه درس‌های انتخاب شده
                final selectedCourses = _cachedCourses?.where((course) {
                      final courseId = course['id'] as int;
                      return _selectedEligibleCourses[courseId] ?? false;
                    }).toList() ??
                    [];

                // لاگ گرفتن
                print('سکشن‌های پاس داده شده به CourseTimetablePage:');
                for (final course in selectedCourses) {
                  final sections = course['sections'] as List<dynamic>? ?? [];
                  print('درس ${course['name']}: ${sections.length} سکشن');
                }

                // پاس دادن همه درس‌ها به صفحه بعد
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseTimetablePage(
                      courses: selectedCourses,
                      hiveService: widget.hiveService,
                      // Add the first selected course ID or a default value
                      courseId: selectedCourses.isNotEmpty
                          ? selectedCourses.first['id'] as int
                          : -1,
                    ),
                  ),
                );
              },
              backgroundColor:
                  darkMode.isDarkMode ? AppColors.darkAccent : AppColors.blue,
              label: Text(
                'ادامه (${_selectedEligibleCourses.values.where((v) => v).length} درس)',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: darkMode.isDarkMode
                      ? AppColors.darkText
                      : AppColors.white,
                ),
              ),
              icon: Icon(
                Icons.arrow_forward,
                color:
                    darkMode.isDarkMode ? AppColors.darkText : AppColors.white,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: darkMode.isDarkMode
            ? AppColors.darkBackground
            : AppColors.blueShade50,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('خطا در بارگذاری دروس: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('هیچ درسی یافت نشد.'));
            }

            final courses = snapshot.data!;
            final filteredCourses = courses.where((course) {
              final sections = course['sections'] as List? ?? [];
              final hasSection = sections.isNotEmpty;

              if (filterOption == 'withSections') {
                return hasSection;
              } else if (filterOption == 'withoutSections') {
                return !hasSection;
              }
              return true; // 'all'
            }).toList();

            final terms = List.generate(8, (index) => <Map<String, dynamic>>[]);
            for (final course in filteredCourses) {
              final termIndex = (course['id'] ~/ 100) - 1;
              if (termIndex >= 0 && termIndex < 8) {
                terms[termIndex].add(course);
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: terms.length + 1,
                    itemBuilder: (context, termIndex) {
                      if (termIndex == terms.length) {
                        return const SizedBox(height: 100.0);
                      }

                      final termCourses = terms[termIndex];
                      if (termCourses.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: termHeaderColor(termIndex),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24.0),
                                  topRight: Radius.circular(24.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blackWithOpacity10,
                                    offset: const Offset(0, 2),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Center(
                                child: Text(
                                  'ترم ${termIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: darkMode.isDarkMode
                                        ? AppColors.darkText
                                        : AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Row(
                              children: termCourses.map((course) {
                                final isSelected = widget.selectedCourseIds
                                    .contains(course['id']);
                                final isEligibleSelected =
                                    _selectedEligibleCourses[
                                            course['id'] as int] ??
                                        false;
                                return GestureDetector(
                                  onTap: () => _toggleCourseSelection(
                                      course['id'] as int),
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: isEligibleSelected
                                          ? (darkMode.isDarkMode
                                              ? AppColors.darkAccent
                                              : AppColors.blue)
                                          : courseColor(isSelected, termIndex),
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isEligibleSelected
                                              ? (darkMode.isDarkMode
                                                  ? AppColors.darkAccent
                                                      .withAlpha(
                                                          (0.3 * 255).toInt())
                                                  : AppColors.blue.withAlpha(
                                                      (0.3 * 255).toInt()))
                                              : AppColors.blackWithOpacity10,
                                          offset: const Offset(0, 4),
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                course['name'] ??
                                                    course['course_name'] ??
                                                    'درس ناشناخته',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: isEligibleSelected
                                                      ? (darkMode.isDarkMode
                                                          ? AppColors.darkText
                                                          : AppColors.white)
                                                      : (darkMode.isDarkMode
                                                          ? AppColors.darkText
                                                          : AppColors.black),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                '${course['units'] ?? 0} واحد',
                                                style: TextStyle(
                                                  color: isEligibleSelected
                                                      ? (darkMode.isDarkMode
                                                          ? AppColors.darkText
                                                          : AppColors.white)
                                                      : (darkMode.isDarkMode
                                                          ? AppColors.darkText
                                                          : AppColors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isEligibleSelected)
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Icon(
                                              Icons.check_circle,
                                              color: darkMode.isDarkMode
                                                  ? AppColors.darkText
                                                  : AppColors.white,
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
