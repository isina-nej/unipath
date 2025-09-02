import 'package:hive/hive.dart';

part 'course_model.g.dart';

@HiveType(typeId: 0)
class CourseModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int units;

  @HiveField(3)
  final List<int> prerequisites;

  @HiveField(4)
  final List<int> corequisites;

  CourseModel({
    required this.id,
    required this.name,
    required this.units,
    List<int>? prerequisites,
    List<int>? corequisites,
  })  : prerequisites = prerequisites ?? [],
        corequisites = corequisites ?? [];

  factory CourseModel.fromJson(Map<dynamic, dynamic> json) {
    // Parse course data, supporting both old and new formats
    final courseData = json['course'] as Map<dynamic, dynamic>? ?? json;

    int parseIntSafely(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    List<int> parseIntList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((e) => parseIntSafely(e))
            .where((e) => e != 0)
            .toList();
      }
      return [];
    }

    return CourseModel(
      id: parseIntSafely(courseData['id']),
      name: (courseData['course_name'] ?? courseData['name'] ?? '').toString(),
      units: parseIntSafely(courseData['number_unit'] ?? courseData['units']),
      prerequisites: parseIntList(courseData['prerequisites']),
      corequisites: parseIntList(courseData['corequisites']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course_name': name,
      'units': units,
      'number_unit': units,
      'prerequisites': prerequisites,
      'corequisites': corequisites,
    };
  }
}
