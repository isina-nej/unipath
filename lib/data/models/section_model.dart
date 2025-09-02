import 'package:hive/hive.dart';
import 'dart:convert';
import 'section_time_model.dart';

part 'section_model.g.dart';

@HiveType(typeId: 1)
class SectionModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int courseId;

  @HiveField(2)
  final String instructorName;

  @HiveField(3)
  final List<SectionTimeModel> times;

  @HiveField(4)
  final List<String> classes;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final DateTime? examTime;

  @HiveField(7)
  final int capacity;

  SectionModel({
    required this.id,
    required this.courseId,
    required this.instructorName,
    List<SectionTimeModel>? times,
    List<String>? classes,
    String? description,
    this.examTime,
    required this.capacity,
  })  : times = times ?? [],
        classes = classes ?? [],
        description = description ?? '';

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct data and nested section data
    final sectionData = json['section'] as Map<String, dynamic>? ?? json;

    try {
      print('Parsing section data: $sectionData');

      final id = int.tryParse(sectionData['id']?.toString() ?? '') ??
          int.tryParse(sectionData['section_id']?.toString() ?? '') ??
          0;

      final courseId =
          int.tryParse(sectionData['course_id']?.toString() ?? '') ?? 0;

      List<SectionTimeModel> parseTimes(dynamic value) {
        if (value == null) return [];

        try {
          if (value is String) {
            // Try parsing JSON string
            final decoded = jsonDecode(value);
            value = decoded;
          }

          if (value is List) {
            return value.map((time) {
              if (time is String) {
                return SectionTimeModel.fromJson(jsonDecode(time));
              }
              return SectionTimeModel.fromJson(Map<String, dynamic>.from(time));
            }).toList();
          }

          if (value is Map) {
            return [
              SectionTimeModel.fromJson(Map<String, dynamic>.from(value))
            ];
          }
        } catch (e) {
          print('Error parsing times: $e');
        }
        return [];
      }

      return SectionModel(
        id: id,
        courseId: courseId,
        instructorName: sectionData['instructor_name']?.toString() ?? '',
        times: parseTimes(sectionData['times']),
        classes: (sectionData['classes'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        description: sectionData['description']?.toString() ?? '',
        examTime: sectionData['exam_time'] != null
            ? DateTime.tryParse(sectionData['exam_time'].toString())
            : null,
        capacity: int.tryParse(sectionData['capacity']?.toString() ?? '') ?? 0,
      );
    } catch (e) {
      print('Error creating SectionModel: $e');
      print('Section data that caused error: $sectionData');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'instructor_name': instructorName,
      'times': times.map((e) => e.toJson()).toList(),
      'classes': classes,
      'description': description,
      'exam_datetime': examTime?.toIso8601String(),
      'capacity': capacity,
    };
  }
}
