import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'ApiException: $message (Status: $statusCode)'
      : 'ApiException: $message';
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 10);
  static const int maxRetries = 2;

  // Get all courses
  static Future<List<dynamic>> getCourses({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = filters != null
          ? Uri(
              queryParameters:
                  filters.map((k, v) => MapEntry(k, v.toString()))).query
          : '';
      final url = '/courses/courses/';

      final response = await AuthService.authenticatedRequest('GET', url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? data;
      } else {
        throw ApiException('Failed to load courses', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error fetching courses: ');
    }
  }

  // Get course by ID
  static Future<Map<String, dynamic>> getCourse(int id) async {
    try {
      final response =
          await AuthService.authenticatedRequest('GET', '/courses/courses//');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to load course', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error fetching course: ');
    }
  }

  // Get all sections
  static Future<List<dynamic>> getSections({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = filters != null
          ? Uri(
              queryParameters:
                  filters.map((k, v) => MapEntry(k, v.toString()))).query
          : '';
      final url = '/courses/sections/';

      final response = await AuthService.authenticatedRequest('GET', url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? data;
      } else {
        throw ApiException('Failed to load sections', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error fetching sections: ');
    }
  }

  // Get section by ID
  static Future<Map<String, dynamic>> getSection(int id) async {
    try {
      final response =
          await AuthService.authenticatedRequest('GET', '/courses/sections//');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to load section', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error fetching section: ');
    }
  }

  // Get section times
  static Future<List<dynamic>> getSectionTimes({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = filters != null
          ? Uri(
              queryParameters:
                  filters.map((k, v) => MapEntry(k, v.toString()))).query
          : '';
      final url = '/courses/section-times/';

      final response = await AuthService.authenticatedRequest('GET', url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? data;
      } else {
        throw ApiException('Failed to load section times', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error fetching section times: ');
    }
  }

  // Legacy method for backward compatibility
  static Future<Map<String, dynamic>> getAllUniversityData() async {
    try {
      final courses = await getCourses();
      final sections = await getSections();
      final sectionTimes = await getSectionTimes();

      return {
        'courses': courses,
        'sections': sections,
        'section_times': sectionTimes,
      };
    } catch (e) {
      throw ApiException('Error fetching university data: ');
    }
  }

  // Create course
  static Future<Map<String, dynamic>> createCourse(
      Map<String, dynamic> courseData) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        '/courses/courses/',
        body: courseData,
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to create course', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error creating course: ');
    }
  }

  // Update course
  static Future<Map<String, dynamic>> updateCourse(
      int id, Map<String, dynamic> courseData) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'PUT',
        '/courses/courses//',
        body: courseData,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to update course', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error updating course: ');
    }
  }

  // Delete course
  static Future<void> deleteCourse(int id) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'DELETE',
        '/courses/courses//',
      );

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete course', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error deleting course: ');
    }
  }

  // Insert section (for backward compatibility with HiveService)
  static Future<Map<String, dynamic>> insertSection(
      Map<String, dynamic> sectionData) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        '$baseUrl/courses/sections/',
        body: sectionData,
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to create section', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error creating section: $e');
    }
  }

  // Update section (for backward compatibility with HiveService)
  static Future<Map<String, dynamic>> updateSection(
      int id, Map<String, dynamic> sectionData) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'PUT',
        '$baseUrl/courses/sections/$id/',
        body: sectionData,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to update section', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error updating section: $e');
    }
  }

  // Delete section (for backward compatibility with HiveService)
  static Future<void> deleteSection(int id) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'DELETE',
        '$baseUrl/courses/sections/$id/',
      );

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete section', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Error deleting section: $e');
    }
  }
}
