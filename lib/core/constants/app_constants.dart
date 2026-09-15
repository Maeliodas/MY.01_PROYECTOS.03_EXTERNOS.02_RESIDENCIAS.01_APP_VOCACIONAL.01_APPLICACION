abstract class AppConstants {
  static const String appName = 'Aevum Iter';
  static const String institutionName = 'Instituto Tecnológico de Tuxtepec';
  static const String institutionShortName = 'ITTUX';

  /// URL del backend institucional.
  /// Desarrollo en dispositivo físico:
  /// --dart-define=AEVUM_API_URL=http://IP_DE_TU_PC:8080/api
  /// Producción: usar exclusivamente la URL HTTPS institucional.
  static const String apiBaseUrl = String.fromEnvironment(
    'AEVUM_API_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  /// Credencial de ingestión de la app. En producción debe suministrarse desde
  /// el entorno de compilación y viajar únicamente sobre HTTPS.
  static const String apiKey = String.fromEnvironment(
    'AEVUM_API_KEY',
    defaultValue: '',
  );

  static const String keyFirstTime = 'is_first_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyReduceAnimations = 'reduce_animations';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
