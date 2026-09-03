import 'package:intl/intl.dart';

abstract class AppDateUtils {
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat("dd 'de' MMMM 'de' yyyy", 'es').format(date);
  }
}
