import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class DashboardApi {
  DashboardApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> sendEvaluation(Map<String, dynamic> payload) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/evaluations'),
            headers: {
              'Content-Type': 'application/json',
              if (AppConstants.apiKey.isNotEmpty)
                'Authorization': 'Bearer ${AppConstants.apiKey}',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
