import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier{
  static String? _baseUrl;

  AuthProvider(){
    _baseUrl=const String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:5078/api');
  }

    Future<void> login(String username, String password) async {
      var url = '$_baseUrl/user/login'; 
      try {
        final respone=await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
        );

        if(respone.statusCode==200){
          final responseBody=json.decode(respone.body);
          print('Login successful: $responseBody');
        } else {
          // Login failed
          final responseBody=json.decode(respone.body);
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
}