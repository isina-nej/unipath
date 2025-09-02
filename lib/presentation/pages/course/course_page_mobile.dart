import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/services/hive_service.dart';
import 'show/eligible_courses_page.dart';
import '../../../core/style/colors.dart';
import '../../../../../core/theme/dark_mode_controller.dart';
import '../../../../../shared/widgets/dark_mode_toggle.dart';

class CourseSelectionPageMobile extends StatefulWidget {
  final HiveService hiveService;

  const CourseSelectionPageMobile({
    super.key,
    required this.hiveService,
  });

  @override
  _CourseSelectionPageMobileState createState() =>
      _CourseSelectionPageMobileState();
}

class _CourseSelectionPageMobileState extends State<CourseSelectionPageMobile> {
  final Map<int, bool> _selectedCourses = {};
  List<Map<String, dynamic>>? _cachedCourses;
  bool _isLoading = true;
  final DarkModeController darkMode = DarkModeController();

  @override
  void initState() {
    super.initState();
    darkMode.addListener(_onThemeChanged);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      print('\n=== شروع بارگذاری داده‌ها از کش ===');
      final allData = await widget.hiveService.getAllData();
      final courseMap = allData['course_map'] as Map<String, dynamic>?;
      print('تعداد دروس در course_map: ${courseMap?.length ?? 0}');

      if (courseMap == null || courseMap.isEmpty) {
        print('هیچ درسی در کش یافت نشد');
        setState(() {
          _cachedCourses = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هیچ درسی در کش یافت نشد')),
        );
        return;
      }

      print('شروع پردازش دروس...');
      final coursesList = courseMap.values
          .map((courseData) {
            try {
              print('Processing course data: ${courseData['course']}');

              final course = courseData['course'] as Map<String, dynamic>?;
              if (course == null) {
                print('داده درس یافت نشد: $courseData');
                return null;
              }

              final id = course['id'];
              if (id == null) {
                print('درس بدون شناسه: $course');
                return null;
              }

              // Extract prerequisites from the list
              final prerequisites = <Map<String, dynamic>>[];
              final rawPrereqs = courseData['prerequisites'] as List? ?? [];
              for (final prereq in rawPrereqs) {
                if (prereq is Map<String, dynamic>) {
                  for (int i = 1; i <= 3; i++) {
                    final prereqId = prereq['prerequisite_$i'];
                    if (prereqId != null) {
                      prerequisites.add({'id': prereqId});
                    }
                  }
                }
              }

              // Extract corequisites from the list
              final corequisites = <Map<String, dynamic>>[];
              final rawCoreqs = courseData['corequisites'] as List? ?? [];
              for (final coreq in rawCoreqs) {
                if (coreq is Map<String, dynamic>) {
                  for (int i = 1; i <= 3; i++) {
                    final coreqId = coreq['corequisites_$i'];
                    if (coreqId != null) {
                      corequisites.add({'id': coreqId});
                    }
                  }
                }
              }

              final processedCourse = {
                'id': id,
                'name': course['name'] ?? 'درس ناشناخته',
                'course_name':
                    course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
                'units': course['units'] ?? course['number_unit'] ?? 0,
                'prerequisites': prerequisites,
                'corequisites': corequisites,
              };
              print(
                  'درس پردازش شد - شناسه: ${processedCourse['id']}, نام: ${processedCourse['course_name']}');
              return processedCourse;
            } catch (e) {
              print('خطا در پردازش داده درس: $courseData\nخطا: $e');
              return null;
            }
          })
          .where((course) => course != null)
          .cast<Map<String, dynamic>>()
          .toList();

      print('تعداد کل دروس پردازش شده: ${coursesList.length}');

      if (coursesList.isEmpty) {
        print('خطا: هیچ درسی پس از پردازش باقی نماند');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در پردازش اطلاعات دروس')),
        );
      }

      if (mounted) {
        setState(() {
          _cachedCourses = coursesList;
          _isLoading = false;
        });
        print('=== پایان بارگذاری داده‌ها ===\n');
      }
    } catch (e) {
      print('خطای کلی در بارگذاری دروس از کش: $e');
      if (mounted) {
        setState(() {
          _cachedCourses = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری دروس: $e')),
        );
      }
    }
  }

  Future<void> _selectCourseWithDependencies(int courseId,
      {bool isPrimary = true}) async {
    if (_cachedCourses == null) return;

    setState(() {
      _selectedCourses[courseId] = true;
    });

    // Find the course data
    final courseData = _cachedCourses!.firstWhere(
      (course) => course['id'] == courseId,
      orElse: () => {'prerequisites': [], 'corequisites': []},
    );

    // Process prerequisites
    final prerequisites = courseData['prerequisites'] as List? ?? [];
    print('Prerequisites for course $courseId: $prerequisites');
    for (final prerequisite in prerequisites) {
      final prerequisiteId = prerequisite['id'] as int?;
      if (prerequisiteId != null &&
          !_selectedCourses.containsKey(prerequisiteId)) {
        await _selectCourseWithDependencies(prerequisiteId, isPrimary: false);
      }
    }

    // Process corequisites
    final corequisites = courseData['corequisites'] as List? ?? [];
    print('Corequisites for course $courseId: $corequisites');
    for (final corequisite in corequisites) {
      final corequisiteId = corequisite['id'] as int?;
      if (corequisiteId != null &&
          !_selectedCourses.containsKey(corequisiteId)) {
        setState(() {
          _selectedCourses[corequisiteId] = true;
        });
      }
    }
  }

  Future<void> _deselectCourseWithDependencies(int courseId) async {
    if (_cachedCourses == null) return;

    setState(() {
      _selectedCourses[courseId] = false;
    });

    // Find dependent courses (courses that have this course as a prerequisite)
    final dependentCourses = _cachedCourses!.where((course) {
      final prerequisites = course['prerequisites'] as List? ?? [];
      return prerequisites.any((prereq) => prereq['id'] == courseId);
    }).toList();

    // Find corequisite courses
    final courseData = _cachedCourses!.firstWhere(
      (course) => course['id'] == courseId,
      orElse: () => {'corequisites': []},
    );
    final corequisites = courseData['corequisites'] as List? ?? [];

    // Deselect dependent courses
    for (final dependent in dependentCourses) {
      final dependentId = dependent['id'] as int?;
      if (dependentId != null && (_selectedCourses[dependentId] ?? false)) {
        await _deselectCourseWithDependencies(dependentId);
      }
    }

    // Deselect corequisites
    for (final corequisite in corequisites) {
      final corequisiteId = corequisite['id'] as int?;
      if (corequisiteId != null && (_selectedCourses[corequisiteId] ?? false)) {
        setState(() {
          _selectedCourses[corequisiteId] = false;
        });
      }
    }
  }

  Future<void> _toggleCourseSelection(int courseId) async {
    if (_selectedCourses[courseId] == true) {
      await _deselectCourseWithDependencies(courseId);
    } else {
      await _selectCourseWithDependencies(courseId);
    }
  }

  void _navigateToEligibleCoursesPage(BuildContext context) {
    final selectedCourses = _selectedCourses.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    Get.to(
      () => EligibleCoursesPage(
        selectedCourseIds: selectedCourses,
        hiveService: widget.hiveService,
      ),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    darkMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cachedCourses == null) {
      return const Scaffold(
        body: Center(child: Text('No courses found')),
      );
    }

    final termColors = [
      AppColors.redShade100,
      AppColors.blueShade100,
      AppColors.greenShade100,
      AppColors.cyanShade100,
      AppColors.orangeShade100,
      AppColors.purpleShade100,
      AppColors.tealShade100,
      AppColors.pinkShade100,
    ];

    final selectedTermColors = darkMode.isDarkMode
        ? [
            AppColors.darkPinkSelected,
            AppColors.darkBlueSelected,
            AppColors.darkGreenSelected,
            AppColors.darkCyanSelected,
            AppColors.darkOrangeSelected,
            AppColors.darkPurpleSelected,
            AppColors.darkTealSelected,
            AppColors.darkRedSelected,
          ]
        : [
            AppColors.pinkShade700,
            AppColors.blueShade900,
            AppColors.greenShade700,
            AppColors.cyanShade700,
            AppColors.orangeShade700,
            AppColors.purpleShade700,
            AppColors.tealShade800,
            AppColors.redShade700,
          ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkAppBarBackground
            : AppColors.appBarBackground,
        title: Builder(
          builder: (context) {
            if (_cachedCourses == null || _cachedCourses!.isEmpty) {
              return const Text(
                'انتخاب دروس',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            final courses = _cachedCourses!;
            int selectedCount = _selectedCourses.values
                .where((isSelected) => isSelected)
                .length;
            int totalUnits = _selectedCourses.entries
                .where((entry) => entry.value)
                .map((entry) {
              final course = courses.firstWhere(
                (course) => course['id'] == entry.key,
                orElse: () => {'units': 0},
              );
              return course['units'] as int? ?? 0;
            }).fold(0, (sum, units) => sum + units);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selectedCount درس',
                  style: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : AppColors.appBarText,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalUnits واحد',
                  style: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.appBarText,
                    fontSize: 12.0,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: darkMode.isDarkMode ? AppColors.darkIcon : AppColors.white,
            ),
            onPressed: () {
              setState(() {
                _selectedCourses.clear();
              });
            },
            tooltip: 'ریست سلکت',
          ),
          DarkModeToggle(controller: darkMode),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16.0),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'لطفاً دروس پاس شده خود را انتخاب کنید',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkMode.isDarkMode
                      ? AppColors.darkText
                      : AppColors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToEligibleCoursesPage(context),
          label: Text(
            'ادامه',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: darkMode.isDarkMode ? AppColors.darkText : AppColors.white,
            ),
          ),
          icon: Icon(
            Icons.arrow_back,
            color: DarkModeController().isDarkMode
                ? AppColors.darkText
                : AppColors.white,
          ),
          backgroundColor: darkMode.isDarkMode
              ? AppColors.darkCardBackground
              : AppColors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: darkMode.isDarkMode
            ? AppColors.darkBackground
            : AppColors.blueShade50,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (_cachedCourses == null || _cachedCourses!.isEmpty) {
              return const Center(child: Text('هیچ درسی یافت نشد.'));
            }

            final courses = _cachedCourses!;

            final terms = List.generate(8, (index) => <Map<String, dynamic>>[]);
            for (final course in courses) {
              if (course['id'] != null) {
                final termIndex = (course['id'] as int) ~/ 100 - 1;
                if (termIndex >= 0 && termIndex < 8) {
                  // Ensure course has all required fields
                  final processedCourse = {
                    'id': course['id'],
                    'name': course['name'] ?? 'درس ناشناخته',
                    'course_name': course['course_name'] ??
                        course['name'] ??
                        'درس ناشناخته',
                    'units': course['units'] ?? 0,
                    'number_unit': course['units'] ?? 0,
                  };
                  terms[termIndex].add(processedCourse);
                }
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
                      final allSelected = termCourses.every(
                          (course) => _selectedCourses[course['id']] ?? false);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: GestureDetector(
                              onTap: () async {
                                final allSelected = termCourses.every(
                                    (course) =>
                                        _selectedCourses[course['id']] ??
                                        false);
                                for (final course in termCourses) {
                                  if (allSelected) {
                                    await _toggleCourseSelection(course['id']);
                                  } else {
                                    await _selectCourseWithDependencies(
                                        course['id']);
                                  }
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: darkMode.isDarkMode
                                      ? (allSelected
                                          ? selectedTermColors[termIndex %
                                                  selectedTermColors.length]
                                              .withOpacity(0.8)
                                          : AppColors.darkCardBackground)
                                      : (allSelected
                                          ? selectedTermColors[termIndex %
                                              selectedTermColors.length]
                                          : termColors[
                                                  termIndex % termColors.length]
                                              .withOpacity(0.3)),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24.0),
                                    topRight: Radius.circular(24.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DarkModeController().isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  border: DarkModeController().isDarkMode
                                      ? Border.all(
                                          color: allSelected
                                              ? AppColors.darkPrimary
                                              : AppColors.darkDivider,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: Text(
                                    'ترم ${termIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      color: allSelected
                                          ? AppColors.white
                                          : Colors.grey.shade700,
                                    ),
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
                                final isSelected =
                                    _selectedCourses[course['id']] ?? false;
                                return GestureDetector(
                                  onTap: () async {
                                    await _toggleCourseSelection(course['id']);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: 120,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: darkMode.isDarkMode
                                          ? (isSelected
                                              ? selectedTermColors[termIndex %
                                                  selectedTermColors.length]
                                              : AppColors.darkCardBackground)
                                          : (isSelected
                                              ? selectedTermColors[termIndex %
                                                  selectedTermColors.length]
                                              : termColors[termIndex %
                                                      termColors.length]
                                                  .withOpacity(0.7)),
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: DarkModeController().isDarkMode
                                              ? (isSelected
                                                  ? Colors.black
                                                      .withOpacity(0.5)
                                                  : Colors.black
                                                      .withOpacity(0.2))
                                              : (isSelected
                                                  ? Colors.black
                                                      .withOpacity(0.5)
                                                  : Colors.black
                                                      .withOpacity(0.1)),
                                          offset: const Offset(0, 4),
                                          blurRadius: isSelected ? 12.0 : 6.0,
                                        ),
                                      ],
                                      border: DarkModeController().isDarkMode
                                          ? Border.all(
                                              color: isSelected
                                                  ? AppColors.darkAccent
                                                  : AppColors.darkDivider,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            course['course_name'] ??
                                                course['name'] ??
                                                'درس ناشناخته',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: darkMode.isDarkMode
                                                  ? (isSelected
                                                      ? AppColors.darkText
                                                      : AppColors
                                                          .darkTextSecondary)
                                                  : (isSelected
                                                      ? AppColors.white
                                                      : Colors.black87),
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            '${course['units']} واحد',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: DarkModeController()
                                                      .isDarkMode
                                                  ? (isSelected
                                                      ? AppColors.darkText
                                                      : AppColors
                                                          .darkTextSecondary)
                                                  : (isSelected
                                                      ? AppColors.white
                                                      : Colors.black54),
                                            ),
                                          ),
                                        ],
                                      ),
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
