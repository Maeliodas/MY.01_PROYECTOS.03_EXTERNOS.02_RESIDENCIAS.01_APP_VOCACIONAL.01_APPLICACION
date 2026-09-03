abstract class AppConstants {
  static const String appName = 'Aevum Iter';
  static const String institutionName = 'Instituto Tecnológico de Tuxtepec';
  static const String institutionShortName = 'ITTUX';

  // Endpoint para envío de estadísticas anónimas (Backend Institucional)
  static const String analyticsApiUrl =
      'https://api.ittux.edu.mx/vocacional/analytics';

  // Claves para SharedPreferences
  static const String keyFirstTime = 'is_first_time';
  static const String keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String keyReduceAnimations = 'reduce_animations';
  static const String keyActiveSessionId = 'active_session_id';

  // Tiempos de animación
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
