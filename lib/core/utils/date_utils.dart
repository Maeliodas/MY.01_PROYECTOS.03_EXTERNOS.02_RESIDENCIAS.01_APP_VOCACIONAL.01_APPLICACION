abstract final class DateUtilsApp {
  static String toIsoString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? fromIsoString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    return '$day/$month/$year';
  }

  static String formatDateTime(DateTime dateTime) {
    final date = formatDate(dateTime);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$date $hour:$minute';
  }
}
