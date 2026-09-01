abstract final class AppConstants {
  static const String appName = 'Residencias Profesionales';

  static const Duration splashDuration = Duration(seconds: 2);

  static const int databaseVersion = 1;
  static const String databaseName = 'residencias_app.db';

  static const int minimumAge = 14;
  static const int maximumAge = 30;

  static const int totalTestQuestions = 30;

  static const int riasecDimensions = 6;

  static const int maxTestScore = 10;

  static const String defaultLanguage = 'es';

  static const String apiBaseUrl = '';

  static const Duration networkTimeout = Duration(seconds: 15);
}
