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
          print('Login successful');
        } else {
          // Login failed
          print('Login failed with status: ${respone.statusCode}');
        }

      } catch (e) {
        // Handle any errors that occur during login
        print('Login failed: $e');
      }
    }
}