class AppDateUtils {
  static String now() => DateTime.now().toUtc().toIso8601String();
  static String display(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    return d == null
        ? iso
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
