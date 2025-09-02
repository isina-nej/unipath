import '../../../../data/models/course_model.dart';
import '../../../../data/models/section_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> getAllCourses();
  Future<List<CourseModel>> getCoursesWithSections();
  Future<List<CourseModel>> getCoursesWithoutSections();
  Future<CourseModel?> getCourseById(String id);
  Future<List<SectionModel>> getSectionsForCourse(String courseId);
  Future<void> updateCourse(CourseModel course);
  Future<void> updateSection(SectionModel section);
  Future<DateTime?> getLastUpdateTime();
  Future<void> setLastUpdateTime(DateTime time);
}
