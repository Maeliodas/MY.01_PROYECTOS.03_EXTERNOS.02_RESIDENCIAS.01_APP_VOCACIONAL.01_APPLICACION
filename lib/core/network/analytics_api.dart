import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class AnalyticsApi {
  AnalyticsApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> sendAnalytics({
    required String school,
    required String gender,
    required String nativeLanguage,
    required Map<String, double> riasecScores,
    required String hollandCode,
    required String recommendedCareer,
  }) async {
    if (AppConstants.apiBaseUrl.isEmpty) {
      return false;
    }

    final uri = Uri.parse('${AppConstants.apiBaseUrl}/analytics');

    final body = jsonEncode({
      'school': school,
      'gender': gender,
      'native_language': nativeLanguage,
      'riasec_scores': riasecScores,
      'holland_code': hollandCode,
      'recommended_career': recommendedCareer,
    });

    try {
      final response = await _client
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(AppConstants.networkTimeout);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
