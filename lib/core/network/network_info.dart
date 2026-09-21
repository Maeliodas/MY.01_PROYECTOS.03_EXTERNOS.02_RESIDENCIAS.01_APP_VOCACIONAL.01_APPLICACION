import 'dart:io';

import '../constants/app_constants.dart';

class NetworkInfo {
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Verifica contra el backend real (panel web, p. ej. túnel ngrok) en vez
  /// de un host externo. Evita falsos positivos cuando hay internet pero el
  /// túnel está caído, y falsos negativos en redes que bloquean Google.
  static Future<bool> hasBackendConnection({Duration timeout = const Duration(seconds: 3)}) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      var base = AppConstants.apiBaseUrl.trim();
      while (base.endsWith('/')) {
        base = base.substring(0, base.length - 1);
      }
      final root = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
      final request = await client.getUrl(Uri.parse('$root/health')).timeout(timeout);
      final response = await request.close().timeout(timeout);
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
