import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class AnalyticsApi {
  final http.Client _client;

  AnalyticsApi({http.Client? client}) : _client = client ?? http.Client();

  /// Envía el payload estrictamente anónimo autorizado al servidor institucional
  Future<bool> sendAnonymousResult(Map<String, dynamic> payload) async {
    try {
      final response = await _client
          .post(
            Uri.parse(AppConstants.analyticsApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
