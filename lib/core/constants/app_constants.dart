class AppConstants {
  static const testQuestionCount = 30;
  static const questionsPerDimension = 5;
  static const minSliderValue = 0;
  static const maxSliderValue = 9;
  static const analyticsApiBaseUrl = String.fromEnvironment(
    'ANALYTICS_API_BASE_URL',
    defaultValue: '',
  );
}
