import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // Get stored tokens
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access': prefs.getString(tokenKey),
      'refresh': prefs.getString(refreshTokenKey),
    };
  }

  // Store tokens
  static Future<void> _storeTokens(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Clear tokens
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storeTokens(data['access'], data['refresh']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Refresh token
  static Future<String?> refreshToken() async {
    final tokens = await getTokens();
    final refreshToken = tokens['refresh'];

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access'];
      await _storeTokens(newAccessToken, refreshToken);
      return newAccessToken;
    } else {
      await logout(); // Clear tokens if refresh fails
      return null;
    }
  }

  // Get authenticated headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final tokens = await getTokens();
    final accessToken = tokens['access'];

    if (accessToken == null) {
      throw Exception('No access token available');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  // Make authenticated request with automatic token refresh
  static Future<http.Response> authenticatedRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    var headers = await getAuthHeaders();

    late http.Response response;

    if (method == 'GET') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else if (method == 'POST') {
      response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    } else if (method == 'PUT') {
      response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    } else if (method == 'PATCH') {
      response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    } else if (method == 'DELETE') {
      response = await http.delete(Uri.parse(url), headers: headers);
    }

    // If token is expired, try to refresh and retry
    if (response.statusCode == 401) {
      final newToken = await refreshToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';
        // Retry the request
        if (method == 'GET') {
          response = await http.get(Uri.parse(url), headers: headers);
        } else if (method == 'POST') {
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
        } else if (method == 'PUT') {
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
        } else if (method == 'PATCH') {
          response = await http.patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
        } else if (method == 'DELETE') {
          response = await http.delete(Uri.parse(url), headers: headers);
        }
      }
    }

    return response;
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final tokens = await getTokens();
    return tokens['access'] != null;
  }
}
