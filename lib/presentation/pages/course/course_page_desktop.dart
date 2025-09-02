import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/hive_service.dart';
import 'show/eligible_courses_page.dart';
import '../../../core/style/colors.dart';
import '../../../core/theme/dark_mode_controller.dart';
import '../../../shared/widgets/dark_mode_toggle.dart';

class CourseSelectionPageDesktop extends StatefulWidget {
  final HiveService hiveService;

  const CourseSelectionPageDesktop({
    super.key,
    required this.hiveService,
  });

  @override
  _CourseSelectionPageDesktopState createState() =>
      _CourseSelectionPageDesktopState();
}

class _CourseSelectionPageDesktopState
    extends State<CourseSelectionPageDesktop> {
  final Map<int, bool> _selectedCourses = {};
  List<Map<String, dynamic>>? _cachedCourses;
  bool _isLoading = true;
  final DarkModeController darkMode = DarkModeController();
  int _selectedTermIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
        _showSnackBar('هیچ درسی در کش یافت نشد');
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
        _showSnackBar('خطا در پردازش اطلاعات دروس');
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
        _showSnackBar('خطا در بارگذاری دروس: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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

  List<List<Map<String, dynamic>>> _getTermsData() {
    if (_cachedCourses == null) return [];

    final terms = List.generate(8, (index) => <Map<String, dynamic>>[]);
    for (final course in _cachedCourses!) {
      if (course['id'] != null) {
        final termIndex = (course['id'] as int) ~/ 100 - 1;
        if (termIndex >= 0 && termIndex < 8) {
          final processedCourse = {
            'id': course['id'],
            'name': course['name'] ?? 'درس ناشناخته',
            'course_name':
                course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
            'units': course['units'] ?? 0,
            'number_unit': course['units'] ?? 0,
            'prerequisites': course['prerequisites'] ?? [],
            'corequisites': course['corequisites'] ?? [],
          };

          // Apply search filter
          if (_searchQuery.isEmpty ||
              processedCourse['course_name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              processedCourse['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) {
            terms[termIndex].add(processedCourse);
          }
        }
      }
    }
    return terms;
  }

  @override
  void dispose() {
    darkMode.removeListener(_onThemeChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkBackground
            : AppColors.blueShade50,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('در حال بارگذاری دروس...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_cachedCourses == null || _cachedCourses!.isEmpty) {
      return Scaffold(
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkBackground
            : AppColors.blueShade50,
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('هیچ درسی یافت نشد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('لطفاً ابتدا دروس را از سرور دانلود کنید'),
            ],
          ),
        ),
      );
    }

    final terms = _getTermsData();
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
      backgroundColor: darkMode.isDarkMode
          ? AppColors.darkBackground
          : AppColors.blueShade50,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Left Sidebar - Terms List
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: darkMode.isDarkMode
                  ? AppColors.darkCardBackground
                  : AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(2, 0),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'جستجوی درس...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: darkMode.isDarkMode
                          ? AppColors.darkBackground
                          : AppColors.blueShade50,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Terms List
                Expanded(
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final termCourses = terms[index];
                      final isSelected = _selectedTermIndex == index;
                      final hasSelectedCourses = termCourses.any(
                        (course) => _selectedCourses[course['id']] ?? false,
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? termColors[index % termColors.length]
                                  .withOpacity(0.2)
                              : null,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: hasSelectedCourses
                                ? selectedTermColors[
                                    index % selectedTermColors.length]
                                : termColors[index % termColors.length],
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            'ترم ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkMode.isDarkMode
                                  ? AppColors.darkText
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '${termCourses.length} درس',
                            style: TextStyle(
                              color: darkMode.isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey.shade600,
                            ),
                          ),
                          trailing: hasSelectedCourses
                              ? Icon(
                                  Icons.check_circle,
                                  color: selectedTermColors[
                                      index % selectedTermColors.length],
                                )
                              : const Icon(Icons.chevron_left),
                          onTap: () {
                            setState(() {
                              _selectedTermIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right Content - Course Grid
          Expanded(
            child: Column(
              children: [
                // Term Header and Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkMode.isDarkMode
                        ? AppColors.darkCardBackground
                        : AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: termColors[
                              _selectedTermIndex % termColors.length],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ترم ${_selectedTermIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${terms[_selectedTermIndex].length} درس موجود',
                        style: TextStyle(
                          color: darkMode.isDarkMode
                              ? AppColors.darkTextSecondary
                              : Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final termCourses = terms[_selectedTermIndex];
                          final allSelected = termCourses.every(
                            (course) => _selectedCourses[course['id']] ?? false,
                          );

                          for (final course in termCourses) {
                            if (allSelected) {
                              await _toggleCourseSelection(course['id']);
                            } else {
                              await _selectCourseWithDependencies(course['id']);
                            }
                          }
                        },
                        icon: const Icon(Icons.select_all),
                        label: Text(
                          terms[_selectedTermIndex].every(
                            (course) => _selectedCourses[course['id']] ?? false,
                          )
                              ? 'لغو انتخاب همه'
                              : 'انتخاب همه',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: termColors[
                              _selectedTermIndex % termColors.length],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Course Grid
                Expanded(
                  child: _buildCourseGrid(
                      terms[_selectedTermIndex], _selectedTermIndex),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final selectedCount =
        _selectedCourses.values.where((isSelected) => isSelected).length;
    int totalUnits = 0;

    if (_cachedCourses != null) {
      totalUnits =
          _selectedCourses.entries.where((entry) => entry.value).map((entry) {
        final course = _cachedCourses!.firstWhere(
          (course) => course['id'] == entry.key,
          orElse: () => {'units': 0},
        );
        return course['units'] as int? ?? 0;
      }).fold(0, (sum, units) => sum + units);
    }

    return AppBar(
      elevation: 0,
      backgroundColor: darkMode.isDarkMode
          ? AppColors.darkAppBarBackground
          : AppColors.appBarBackground,
      title: Row(
        children: [
          const Icon(Icons.school, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'انتخاب دروس',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                '$selectedCount درس انتخاب شده • $totalUnits واحد',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedCourses.clear();
              _searchQuery = '';
              _searchController.clear();
            });
          },
          tooltip: 'ریست انتخاب‌ها',
        ),
        const SizedBox(width: 8),
        DarkModeToggle(controller: darkMode),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCourseGrid(List<Map<String, dynamic>> courses, int termIndex) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'هیچ درسی با عبارت "$_searchQuery" یافت نشد'
                  : 'هیچ درسی در این ترم موجود نیست',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final isSelected = _selectedCourses[course['id']] ?? false;
        final hasPrerequisites = (course['prerequisites'] as List).isNotEmpty;
        final hasCorequisites = (course['corequisites'] as List).isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: darkMode.isDarkMode
                ? (isSelected
                    ? selectedTermColors[termIndex % selectedTermColors.length]
                    : AppColors.darkCardBackground)
                : (isSelected
                    ? selectedTermColors[termIndex % selectedTermColors.length]
                    : Colors.white),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? selectedTermColors[termIndex % selectedTermColors.length]
                        .withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: isSelected ? 12.0 : 6.0,
              ),
            ],
            border: Border.all(
              color: isSelected
                  ? selectedTermColors[termIndex % selectedTermColors.length]
                  : (darkMode.isDarkMode
                      ? AppColors.darkDivider
                      : Colors.grey.shade200),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => _toggleCourseSelection(course['id']),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : termColors[termIndex % termColors.length]
                                  .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${course['units']} واحد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : termColors[termIndex % termColors.length],
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Course Name
                  Expanded(
                    child: Text(
                      course['course_name'] ?? course['name'] ?? 'درس ناشناخته',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (darkMode.isDarkMode
                                ? AppColors.darkText
                                : Colors.black87),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Prerequisites and Corequisites indicators
                  Row(
                    children: [
                      if (hasPrerequisites)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'پیش‌نیاز',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (hasPrerequisites && hasCorequisites)
                        const SizedBox(width: 4),
                      if (hasCorequisites)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'هم‌نیاز',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    final selectedCount = _selectedCourses.values.where((v) => v).length;

    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToEligibleCoursesPage(context),
        icon: const Icon(Icons.arrow_forward, color: Colors.white),
        label: Text(
          'ادامه ($selectedCount درس انتخاب شده)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blue,
        elevation: 8,
      ),
    );
  }
}
