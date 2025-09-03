import 'package:get/get.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  var isAuthenticated = false.obs;
  var isLoading = false.obs;
  var userProfile = {}.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    isLoading.value = true;
    try {
      isAuthenticated.value = await AuthService.isAuthenticated();
      if (isAuthenticated.value) {
        // Load user profile if authenticated
        await loadUserProfile();
      }
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final result = await AuthService.login(username, password);
      isAuthenticated.value = true;
      await loadUserProfile();
      Get.snackbar('Success', 'Login successful');
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
  }) async {
    isLoading.value = true;
    try {
      final result = await AuthService.register(
        username: username,
        email: email,
        password: password,
        password2: password2,
        firstName: firstName,
        lastName: lastName,
      );
      Get.snackbar('Success', 'Registration successful. Please login.');
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await AuthService.logout();
      isAuthenticated.value = false;
      userProfile.value = {};
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await AuthService.authenticatedRequest(
          'GET', 'http://localhost:8000/api/v1/auth/profile/');

      if (response.statusCode == 200) {
        userProfile.value = response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }
}
