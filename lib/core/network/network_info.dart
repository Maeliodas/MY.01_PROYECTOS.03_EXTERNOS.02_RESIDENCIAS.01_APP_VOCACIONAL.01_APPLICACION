import 'dart:io';

class NetworkInfo {
  Future<bool> get isConnected async {
    try {
      final r = await InternetAddress.lookup('example.com');
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
