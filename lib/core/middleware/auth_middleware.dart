import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../routing/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If user is not authenticated and trying to access protected routes
    if (!authController.isAuthenticated.value &&
        (route == AppRoutes.home ||
            route == AppRoutes.course ||
            route == AppRoutes.schedule ||
            route == AppRoutes.courseRegistration)) {
      return RouteSettings(name: AppRoutes.login);
    }

    // If user is authenticated and trying to access auth routes
    if (authController.isAuthenticated.value &&
        (route == AppRoutes.login || route == AppRoutes.register)) {
      return RouteSettings(name: AppRoutes.home);
    }

    return null; // No redirect needed
  }
}
