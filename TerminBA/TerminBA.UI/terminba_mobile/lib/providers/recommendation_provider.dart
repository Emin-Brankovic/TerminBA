import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:terminba_mobile/model/recommendation_result.dart';
import 'package:terminba_mobile/providers/base_provider.dart';

class RecommendationProvider extends ChangeNotifier {
  static String? _baseUrl;

  List<RecommendationResult> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RecommendationResult> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasRecommendations => _recommendations.isNotEmpty;

  RecommendationProvider() {
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'http://10.0.2.2:5078/api/',
    );
  }

  /// Fetches personalised recommendations for [userId] from the backend.
  /// Falls back to non-personalised top-rated facilities if history is thin.
  Future<void> loadRecommendations(int userId, {int topN = 5}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = '${_baseUrl}recommendations/$userId?topN=$topN';
      final uri = Uri.parse(url);
      final headers = await BaseProvider.createStaticHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _recommendations =
            data.map((e) => RecommendationResult.fromJson(e)).toList();
      } else if (response.statusCode == 503) {
        // Model not yet trained — silently show nothing
        _recommendations = [];
      } else {
        _recommendations = [];
        _errorMessage = 'Preporuke trenutno nisu dostupne.';
      }
    } catch (_) {
      _recommendations = [];
      // Silently fail — home screen degrades gracefully without recommendations
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _recommendations = [];
    _errorMessage = null;
    notifyListeners();
  }
}
