import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:terminba_sport_center_desktop/main.dart';
import 'package:terminba_sport_center_desktop/screens/login_screen.dart';

class AuthProvider extends ChangeNotifier {
  static String? _baseUrl;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'http://localhost:5078/api',
    );
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && !JwtDecoder.isExpired(token)) {
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
    var url = '$_baseUrl/SportCenter/login';
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
        _isLoggedIn = true;
        notifyListeners();
        print("Login successful, token stored.");
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

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _isLoggedIn = false;
    notifyListeners();
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }
}
