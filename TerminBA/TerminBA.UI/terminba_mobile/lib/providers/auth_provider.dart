import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:terminba_mobile/main.dart';
import 'package:terminba_mobile/screens/login_screen.dart';
import 'package:terminba_mobile/layouts/master_screen_bottom_nav.dart';
import 'package:terminba_mobile/providers/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  static String? _baseUrl;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _currentUsername;
  String get currentUsername => _currentUsername ?? 'User';

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'http://10.0.2.2:5078/api',
    );
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && !JwtDecoder.isExpired(token)) {
      try {
        final claims = JwtDecoder.decode(token);
        _currentUsername = claims['unique_name']?.toString();
      } catch (_) {
        _currentUsername = null;
      }
      _isLoggedIn = true;
      notifyListeners();
    } else {
      await logout();
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> login(String username, String password, int roleId) async {
    var url = '$_baseUrl/User/login';
    try {
      final respone = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'roleId': roleId.toString(),
        }),
      );

      if (respone.statusCode == 200) {
        final responseBody = json.decode(respone.body);
        final token = responseBody['accessToken'];

        await _storage.write(key: _tokenKey, value: token);
        try {
          final claims = JwtDecoder.decode(token);
          _currentUsername = claims['unique_name']?.toString();
        } catch (_) {
          _currentUsername = null;
        }
        _isLoggedIn = true;
        notifyListeners();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MasterScreenBottomNav()),
          (route) => false,
        );
      } else {
        // Login failed
        final responseBody = json.decode(respone.body);
        // Extract error message from response
        String errorMessage = 'Invalid credentials';
        if (responseBody is Map && responseBody.containsKey('message')) {
          errorMessage = responseBody['message'];
        } else if (responseBody is String) {
          errorMessage = responseBody;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Re-throw exception if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      // Handle any other errors that occur during login
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<int?> getCurrentUserId() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;
    try {
      final claims = JwtDecoder.decode(token);
      final raw = claims['nameid'];
      if (raw == null) return null;
      return int.tryParse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  Future<String?> getCurrentUsername() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;
    try {
      final claims = JwtDecoder.decode(token);
      final raw = claims['unique_name'];
      if (raw == null) return null;
      return raw.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/User/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 2));
      }
    } catch (_) {
      // Best-effort remote revocation
    } finally {
      await _storage.delete(key: _tokenKey);
      try {
        await NotificationService().stop();
      } catch (_) {}
      _isLoggedIn = false;
      _currentUsername = null;
      notifyListeners();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String confirmCurrentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/User/changePassword'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'confirmCurrentPassword': confirmCurrentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );

    if (response.statusCode != 200) {
      String errorMessage = 'Failed to change password';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('errors')) {
          errorMessage = body['errors']['userError']?.first?.toString() ?? errorMessage;
        } else if (body is String) {
          errorMessage = body;
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  String _extractError(http.Response response, String fallbackMessage) {
    if (response.body.isEmpty) return fallbackMessage;
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body.containsKey('errors') && body['errors'] is Map) {
          final errorsMap = body['errors'] as Map;
          if (errorsMap.containsKey('userError')) {
            final userErrors = errorsMap['userError'];
            if (userErrors is List && userErrors.isNotEmpty) {
              return userErrors.first.toString();
            }
          }
          for (final val in errorsMap.values) {
            if (val is List && val.isNotEmpty) {
              return val.first.toString();
            }
            if (val is String && val.isNotEmpty) {
              return val;
            }
          }
        }
        if (body.containsKey('message') && body['message'] is String) {
          return body['message'] as String;
        }
      } else if (body is String) {
        return body;
      }
    } catch (_) {}
    return fallbackMessage;
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/User/requestPasswordReset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final errorMessage = _extractError(response, 'Failed to request password reset');
      throw Exception(errorMessage);
    }
  }

  Future<void> confirmPasswordReset(
    String email,
    String token,
    String newPassword,
    String confirmNewPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/User/confirmPasswordReset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );

    if (response.statusCode != 200) {
      final errorMessage = _extractError(response, 'Failed to reset password');
      throw Exception(errorMessage);
    }
  }
}
