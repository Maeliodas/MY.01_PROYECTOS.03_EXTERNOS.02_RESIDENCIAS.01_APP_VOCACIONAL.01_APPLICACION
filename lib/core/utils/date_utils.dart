import 'package:intl/intl.dart';

abstract class AppDateUtils {
  static String formatIsoToReadable(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy - hh:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  static String formatIsoToShortDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy', 'es').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}
