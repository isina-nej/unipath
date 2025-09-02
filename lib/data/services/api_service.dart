import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

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
  static const String baseUrl = 'https://isinanej.pythonanywhere.com';
  // Reduced timeout to fail faster during development
  static const Duration timeoutDuration = Duration(seconds: 10);
  // Reduced retries to fail faster during development
  static const int maxRetries = 2;

  static Future<Map<String, dynamic>> getAllUniversityData() async {
    int retryCount = 0;
    late http.Response response;

    while (retryCount < maxRetries) {
      try {
        print('درخواست اطلاعات از سرور... تلاش ${retryCount + 1}');
        response = await http.get(
          Uri.parse('$baseUrl/all_university_data'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(timeoutDuration);

        if (response.statusCode == 200) {
          print('دریافت اطلاعات موفقیت‌آمیز بود');
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            print('فرمت داده‌ها صحیح است');
            return data;
          }
          throw ApiException('فرمت پاسخ نامعتبر است');
        } else if (response.statusCode == 429) {
          print('محدودیت تعداد درخواست. در حال تلاش مجدد...');
          await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
          retryCount++;
          continue;
        } else {
          throw ApiException(
              'خطای سرور: ${response.statusCode} - ${response.reasonPhrase ?? "خطای نامشخص"}',
              response.statusCode);
        }
      } on TimeoutException {
        print('تایم‌اوت در برقراری ارتباط. تلاش مجدد...');
        if (++retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retryCount));
          continue;
        }
        throw ApiException('خطای تایم‌اوت در برقراری ارتباط با سرور');
      } on SocketException {
        print('خطای اتصال به اینترنت. تلاش مجدد...');
        if (++retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retryCount));
          continue;
        }
        throw ApiException('لطفاً اتصال اینترنت خود را بررسی کنید');
      } on FormatException {
        throw ApiException('خطا در پردازش پاسخ سرور');
      } catch (e) {
        print('خطای غیرمنتظره: $e');
        throw ApiException('خطای غیرمنتظره: $e');
      }
    }

    throw ApiException(
        'حداکثر تعداد تلاش‌ها انجام شد. لطفاً بعداً دوباره امتحان کنید.');
  }

  static Future<Map<String, dynamic>> updateSection(
      int sectionId, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/sections/$sectionId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        throw ApiException('Invalid response format');
      } else if (response.statusCode == 404) {
        throw ApiException('Section not found', response.statusCode);
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        throw ApiException(
            responseData['error'] ?? 'Invalid request', response.statusCode);
      }
      throw ApiException(
          'Update failed: ${response.reasonPhrase ?? "Unknown error"}',
          response.statusCode);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: $e');
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: $e');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<Map<String, dynamic>> insertSection(
      Map<String, dynamic> data) async {
    try {
      print('Sending data to server: ${json.encode(data)}');
      final response = await http
          .post(
            Uri.parse('$baseUrl/sections'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(timeoutDuration);

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        throw ApiException('Invalid response format');
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        throw ApiException(
            responseData['error'] ?? 'Invalid request', response.statusCode);
      }
      throw ApiException(
          'Insert failed: ${response.reasonPhrase ?? "Unknown error"}',
          response.statusCode);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: $e');
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: $e');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<void> deleteSection(int sectionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sections/$sectionId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw ApiException('Section not found', response.statusCode);
      }
      throw ApiException(
          'Delete failed: ${response.reasonPhrase ?? "Unknown error"}',
          response.statusCode);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: $e');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<Map<String, dynamic>> getSection(int sectionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sections/$sectionId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        throw ApiException('Invalid response format');
      } else if (response.statusCode == 404) {
        throw ApiException('Section not found', response.statusCode);
      }
      throw ApiException(
          'Failed to get section: ${response.reasonPhrase ?? "Unknown error"}',
          response.statusCode);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: $e');
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: $e');
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}
