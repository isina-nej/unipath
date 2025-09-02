import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../../../../data/services/hive_service.dart';
import 'edit_course_page.dart';
import '../../../../../core/style/sizes.dart';
import '../../../../../core/style/text_styles.dart';
import '../../../../../core/style/colors.dart';
import '../../../../../core/theme/dark_mode_controller.dart';

class SectionPopup extends StatelessWidget {
  final int courseId;
  final String courseName;
  final HiveService hiveService;

  const SectionPopup({
    Key? key,
    required this.courseId,
    required this.courseName,
    required this.hiveService,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchSections(int courseId) async {
    try {
      final data = await hiveService.getAllData();
      final courseMap = data['course_map'] as Map<String, dynamic>?;
      if (courseMap == null) return [];

      // Find the course by its ID in the courseMap
      final courseData = courseMap[courseId
          .toString()]; // Convert ID to string as the map keys are strings
      if (courseData == null) return [];

      final sections = (courseData['sections'] as List?) ?? [];
      return sections
          .where((section) => section != null)
          .map((section) => Map<String, dynamic>.from(section))
          .toList();
    } catch (e) {
      print('Error loading sections from cache: $e');
      return [];
    }
  }

  void _navigateToEditPage(BuildContext context, {int? sectionId}) {
    // ابتدا صفحه فعلی را می‌بندیم و true را برمی‌گردانیم تا صفحه والد به‌روزرسانی شود
    Navigator.of(context).pop(true);

    // سپس صفحه ویرایش را باز می‌کنیم
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCoursePage(
          courseId: courseId,
          courseName: courseName,
          sectionId: sectionId?.toString(),
          hiveService: hiveService,
        ),
      ),
    );
  }

  Future<void> _deleteSection(BuildContext context, int sectionId) async {
    try {
      await hiveService.deleteSection(sectionId.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('سکشن با موفقیت حذف شد'),
            duration: Duration(seconds: 2),
          ),
        );
        // دیالوگ تایید را می‌بندیم
        Navigator.of(context).pop();
        // پاپ‌آپ سکشن را می‌بندیم و true برمی‌گردانیم تا صفحه والد به‌روزرسانی شود
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در حذف سکشن'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildCourseTitle(String text, bool isDarkMode) {
    // اگر متن طولانی‌تر از 20 کاراکتر باشد، از مارکی استفاده می‌کنیم
    if (text.length > 20) {
      return SizedBox(
        height: 24,
        child: Marquee(
          text: text,
          style: AppTextStyles.sectionPopupTitle.copyWith(
            color: isDarkMode ? AppColors.darkText : Colors.black87,
          ),
          scrollAxis: Axis.horizontal,
          blankSpace: 50.0,
          velocity: 50.0,
          startAfter:
              const Duration(seconds: 2), // 2 ثانیه تاخیر قبل از شروع حرکت
          pauseAfterRound: const Duration(seconds: 1),
          startPadding: 10.0,
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      );
    }

    // برای متن‌های کوتاه، نمایش عادی
    return Text(
      text,
      style: AppTextStyles.sectionPopupTitle.copyWith(
        color: isDarkMode ? AppColors.darkText : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeController();
    return Dialog(
      backgroundColor: darkMode.isDarkMode
          ? AppColors.darkDialogBackground
          : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppSizes.dialogRadius,
        side: BorderSide(
          color: darkMode.isDarkMode
              ? AppColors.darkDialogBorder
              : Colors.transparent,
        ),
      ),
      child: Container(
        padding: AppSizes.pagePadding,
        width: AppSizes.dialogMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildCourseTitle(courseName, darkMode.isDarkMode),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: darkMode.isDarkMode
                        ? AppColors.darkAccent
                        : Colors.green,
                  ),
                  tooltip: 'افزودن سکشن جدید',
                  onPressed: () => _navigateToEditPage(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchSections(courseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'خطا در بارگذاری سکشن‌ها',
                        style: AppTextStyles.errorText(darkMode.isDarkMode)
                            .copyWith(
                          color: darkMode.isDarkMode
                              ? AppColors.darkText
                              : Colors.red,
                        ),
                      ),
                    );
                  }

                  final sections = snapshot.data ?? [];
                  if (sections.isEmpty) {
                    return Center(
                      child: Text(
                        'هیچ سکشنی پیدا نشد.',
                        style: AppTextStyles.sectionPopupEmpty.copyWith(
                          color: darkMode.isDarkMode
                              ? AppColors.darkText
                              : Colors.black54,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: sections.length,
                    separatorBuilder: (_, __) => Divider(
                      color: darkMode.isDarkMode
                          ? AppColors.darkDivider
                          : AppColors.greyWithOpacity30,
                    ),
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return InkWell(
                        onTap: () => _navigateToEditPage(
                          context,
                          sectionId: section['id'],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: darkMode.isDarkMode
                                ? AppColors.darkSectionItemBackground
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'سکشن ${section['id']}',
                                        style: AppTextStyles
                                            .sectionPopupListTitle
                                            .copyWith(
                                          color: darkMode.isDarkMode
                                              ? AppColors.darkText
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ظرفیت: ${section['capacity']} | استاد: ${section['instructor_name']}',
                                        style: AppTextStyles
                                            .sectionPopupListSubtitle
                                            .copyWith(
                                          color: darkMode.isDarkMode
                                              ? AppColors.darkTextSecondary
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'حذف سکشن',
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('حذف سکشن'),
                                    content: const Text(
                                        'آیا از حذف این سکشن اطمینان دارید؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('انصراف'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _deleteSection(
                                              context, section['id']);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
