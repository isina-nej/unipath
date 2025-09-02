import 'package:flutter/material.dart';
import 'course_page_mobile.dart';
import 'course_page_desktop.dart';
import '../../../data/services/hive_service.dart';

class CourseSelectionPage extends StatelessWidget {
  final HiveService hiveService;

  const CourseSelectionPage({
    super.key,
    required this.hiveService,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return CourseSelectionPageMobile(hiveService: hiveService);
    } else {
      return CourseSelectionPageDesktop(hiveService: hiveService);
    }
  }
}
