import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:terminba_admin_desktop/model/search_result.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static Future<void> Function()? onUnauthorized;
  static String? _baseUrl;
  String _endpoint = "";
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5078/api/",
    );
  }

  String get baseUrl => _baseUrl ?? "";
  String get endpoint => _endpoint;

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.totalCount = (data['count']) as int?;
      result.items = List<T>.from(data["items"].map((e) => fromJson(e)));

      return result;
    } else {
      throw new Exception("Unknown error");
    }
    // print("response: ${response.request} ${response.statusCode}, ${response.body}");
  }

  Future<T?> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      try {
        var data = jsonDecode(response.body);
        if (data == null) return null;
        final result = fromJson(data);
        return result;
      } catch (e) {
        return null;
      }
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T?> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      try {
        var data = jsonDecode(response.body);
        if (data == null) return null;
        return fromJson(data);
      } catch (_) {
        return null;
      }
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T?> getById(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      try {
        var data = jsonDecode(response.body);
        if (data == null) return null;
        return fromJson(data);
      } catch (_) {
        return null;
      }
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<bool> delete(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw Exception("Unauthorized");
    } else {
      final message = _extractErrorMessage(
        response,
        fallbackMessage: "Something went wrong, please try again",
      );

      if (_isUserExceptionResponse(response)) {
        throw Exception(message);
      }

      if (response.statusCode >= 500) {
        throw Exception(message);
      }

      throw Exception(message);
    }
  }

  bool _isUserExceptionResponse(Response response) {
    if (response.statusCode != 400 || response.body.isEmpty) {
      return false;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return false;
      }

      final errors = data['errors'];
      if (errors is! Map<String, dynamic>) {
        return false;
      }

      final userError = errors['userError'];
      return userError is List && userError.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String _extractErrorMessage(
    Response response, {
    required String fallbackMessage,
  }) {
    if (response.body.isEmpty) {
      return fallbackMessage;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return fallbackMessage;
      }

      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final userError = errors['userError'];
        if (userError is List && userError.isNotEmpty) {
          return userError.first.toString();
        }

        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Fallback to default message when response is not JSON.
    }

    return fallbackMessage;
  }

  Future<Map<String, String>> createHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final String? token = await _storage.read(key: _tokenKey);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }
}
