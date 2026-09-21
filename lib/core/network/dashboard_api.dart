import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class DashboardApi {
  DashboardApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AppConstants.apiKey.isNotEmpty)
          'Authorization': 'Bearer ${AppConstants.apiKey}',
      };

  Future<bool> sendEvaluation(Map<String, dynamic> payload) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/evaluations'),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchCatalogSnapshot() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/catalogs'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  /// Versión ligera del catálogo (pocos bytes). Null si no hay red o el
  /// panel aún no expone el endpoint (paneles viejos).
  Future<int?> fetchCatalogVersion() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/catalog-version'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final version = decoded['version'];
      return version is num ? version.toInt() : int.tryParse('$version');
    } catch (_) {
      return null;
    }
  }

  Future<bool> sendCatalogSuggestion({
    required String kind,
    required String name,
    String? municipalityId,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/catalog-suggestions'),
            headers: _headers,
            body: jsonEncode({'kind': kind, 'name': name, if (municipalityId != null) 'municipality_id': municipalityId}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
