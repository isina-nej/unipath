import 'dart:async';
import 'package:flutter/material.dart';

/// کلاس مدیریت خطاها
/// این کلاس مسئولیت مدیریت و نمایش خطاها را بر عهده دارد
class ErrorHandler {
  // Private constructor
  ErrorHandler._();

  // نمونه Singleton
  static final ErrorHandler _instance = ErrorHandler._();
  static ErrorHandler get instance => _instance;

  /// نمایش SnackBar خطا
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// نمایش SnackBar موفقیت
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// مدیریت خطای عمومی
  static void handleError(BuildContext context, dynamic error) {
    print('خطا رخ داده: $error');
    String message = 'خطای نامشخص رخ داده است';

    if (error is ApiException) {
      message = error.message;
    } else if (error is NetworkException) {
      message = 'لطفاً اتصال اینترنت خود را بررسی کنید';
    } else if (error is TimeoutException) {
      message = 'زمان اتصال به پایان رسید. دوباره امتحان کنید';
    }

    showErrorSnackBar(context, message);
  }
}

/// کلاس خطای API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'ApiException: $message (Status: $statusCode)'
      : 'ApiException: $message';
}

/// کلاس خطای شبکه
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
