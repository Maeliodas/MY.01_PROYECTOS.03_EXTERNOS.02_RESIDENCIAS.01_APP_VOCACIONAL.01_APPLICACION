import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class AnalyticsApi {
  final http.Client client;
  AnalyticsApi({http.Client? client}) : client = client ?? http.Client();
  bool get configured => AppConstants.analyticsApiBaseUrl.isNotEmpty;
  Future<void> send(Map<String, dynamic> payload) async {
    if (!configured) throw StateError('API no configurada');
    final r = await client.post(
      Uri.parse('${AppConstants.analyticsApiBaseUrl}/analytics/results'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw StateError('HTTP ${r.statusCode}');
    }
  }
}
