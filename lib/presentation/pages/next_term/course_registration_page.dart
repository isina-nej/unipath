import 'package:flutter/material.dart';
import '../../../../data/services/hive_service.dart';
import 'eligible_courses/eligible_courses_page.dart';
import '../../../../core/style/text_styles.dart';
import '../../../../core/style/colors.dart';
import '../../../../core/theme/dark_mode_controller.dart';
import '../../../../shared/widgets/dark_mode_toggle.dart';

class CourseRegistrationPage extends StatefulWidget {
  final HiveService hiveService;

  const CourseRegistrationPage({
    super.key,
    required this.hiveService,
  });

  @override
  _CourseRegistrationPage createState() => _CourseRegistrationPage();
}

class _CourseRegistrationPage extends State<CourseRegistrationPage> {
  final Map<int, bool> _selectedCourses = {};
  final Map<int, bool> _courseSections = {};
  List<Map<String, dynamic>>? _cachedCourses;
  late final DarkModeController darkMode;
  bool _isLoading = true;
  bool showOnlySelectedCourses = false;

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.hiveService.getAllData();
      final courseMap = data['course_map'] as Map<String, dynamic>?;
      if (courseMap == null || courseMap.isEmpty) {
        setState(() {
          _cachedCourses = [];
        });
        print('هیچ درسی در کش یافت نشد');
        return;
      }

      // ابتدا سکشن‌ها را بارگذاری می‌کنیم
      final sections = data['sections'] as List?;
      if (sections != null) {
        _loadSections(sections.cast<Map<String, dynamic>>());
      }

      _cachedCourses = courseMap.values
          .map((courseData) {
            try {
              final course = courseData['course'] as Map<String, dynamic>?;
              if (course == null) return null;
              final id = course['id'];
              if (id == null) return null;
              // استخراج نام و تعداد واحد صحیح
              return {
                ...course,
                'name':
                    course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
                'units': course['number_unit'] ?? course['units'] ?? 0,
              };
            } catch (e) {
              print('خطا در پردازش داده درس: $courseData\nخطا: $e');
              return null;
            }
          })
          .where((course) => course != null)
          .cast<Map<String, dynamic>>()
          .toList();
      // استخراج سکشن‌ها از خود course_map
      _courseSections.clear();
      for (final courseData in courseMap.values) {
        final course = courseData['course'] as Map<String, dynamic>?;
        final id = course?['id'];
        final sections = courseData['sections'] as List?;
        if (id != null && sections != null && sections.isNotEmpty) {
          _courseSections[id] = true;
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _cachedCourses = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadSections(List<Map<String, dynamic>> sections) {
    _courseSections.clear();
    for (var section in sections) {
      final courseId = section['course_id'] as int?;
      if (courseId != null) {
        _courseSections[courseId] = true;
      }
    }
  }

  Future<void> _selectCourseWithDependencies(int courseId) async {
    setState(() {
      _selectedCourses[courseId] = true;
    });
  }

  Future<void> _deselectCourseWithDependencies(int courseId) async {
    setState(() {
      _selectedCourses[courseId] = false;
    });
  }

  Future<void> _toggleCourseSelection(int courseId) async {
    if (_selectedCourses[courseId] == true) {
      await _deselectCourseWithDependencies(courseId);
    } else {
      await _selectCourseWithDependencies(courseId);
    }
  }

  void _filterCoursesBySection() {
    if (_cachedCourses == null) return;

    setState(() {
      _selectedCourses.clear();
      for (var courseId in _courseSections.keys) {
        if (_courseSections[courseId] == true) {
          _selectedCourses[courseId] = true;
        }
      }
    });
  }

  void _navigateToEligibleCoursesPage(BuildContext context) {
    final selectedCourses = _selectedCourses.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EligibleCoursesPage(
          selectedCourseIds: selectedCourses,
          cachedCourses: _cachedCourses,
          courseSections: _courseSections,
          hiveService: widget.hiveService,
        ),
      ),
    );
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
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.cyan.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
      Colors.pink.shade100,
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
            Colors.pink.shade700,
            Colors.blue.shade900,
            Colors.green.shade700,
            Colors.cyan.shade700,
            Colors.orange.shade700,
            Colors.purple.shade700,
            Colors.teal.shade800,
            Colors.red.shade700,
          ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkAppBarBackground
            : Colors.indigo,
        title: Text('ثبت دروس ترم بعد',
            style: AppTextStyles.getPageTitle(darkMode.isDarkMode)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color:
                  darkMode.isDarkMode ? AppColors.darkAccent : AppColors.blue,
            ),
            onPressed: _filterCoursesBySection,
          ),
          DarkModeToggle(controller: darkMode),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16.0),
          child: Container(
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'لطفاً دروسی که قرار است ارائه شود را انتخاب کنید',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
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
          label: const Text(
            'ادامه',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.arrow_back),
          backgroundColor: Colors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: darkMode.isDarkMode
            ? AppColors.darkBackground
            : Colors.blue.shade50,
        child: _cachedCourses == null
            ? const Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) {
                  final filteredCourses = showOnlySelectedCourses
                      ? _cachedCourses!
                          .where((course) =>
                              _selectedCourses[course['id']] == true)
                          .toList()
                      : _cachedCourses!;

                  final terms =
                      List.generate(8, (index) => <Map<String, dynamic>>[]);
                  for (final course in filteredCourses) {
                    final termIndex = (course['id'] ~/ 100) - 1;
                    if (termIndex >= 0 && termIndex < 8) {
                      terms[termIndex].add({
                        ...course,
                        'course_name': course['name'] ?? 'درس ناشناخته'
                      });
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
                            final allSelected = termCourses.every((course) =>
                                _selectedCourses[course['id']] ?? false);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final allSelected = termCourses.every(
                                          (course) =>
                                              _selectedCourses[course['id']] ??
                                              false);
                                      for (final course in termCourses) {
                                        if (allSelected) {
                                          await _toggleCourseSelection(
                                              course['id']);
                                        } else {
                                          await _selectCourseWithDependencies(
                                              course['id']);
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: allSelected
                                            ? selectedTermColors[termIndex %
                                                selectedTermColors.length]
                                            : termColors[termIndex %
                                                    termColors.length]
                                                .withOpacity(0.3),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(24.0),
                                          topRight: Radius.circular(24.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Center(
                                        child: Text(
                                          'ترم ${termIndex + 1}',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            color: allSelected
                                                ? Colors.white
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
                                          _selectedCourses[course['id']] ??
                                              false;
                                      return GestureDetector(
                                        onTap: () async {
                                          await _toggleCourseSelection(
                                              course['id']);
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? selectedTermColors[termIndex %
                                                    selectedTermColors.length]
                                                : termColors[termIndex %
                                                        termColors.length]
                                                    .withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                    ? Colors.black
                                                        .withOpacity(0.5)
                                                    : Colors.black
                                                        .withOpacity(0.1),
                                                offset: const Offset(0, 4),
                                                blurRadius:
                                                    isSelected ? 12.0 : 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  course['name'] ??
                                                      'درس ناشناخته',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Text(
                                                  '${course['units'] ?? 0} واحد',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black,
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

  @override
  void dispose() {
    darkMode.removeListener(_onThemeChanged);
    super.dispose();
  }
}
