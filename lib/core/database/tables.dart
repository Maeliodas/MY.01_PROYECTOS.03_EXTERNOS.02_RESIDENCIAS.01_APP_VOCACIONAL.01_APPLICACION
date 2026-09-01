abstract final class DatabaseTables {
  static const String userProfile = 'user_profile';
  static const String testResults = 'test_results';
  static const String answers = 'answers';
  static const String preferences = 'preferences';
}

abstract final class DatabaseSchema {
  static const String createUserProfile = '''
    CREATE TABLE user_profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      gender TEXT,
      school TEXT,
      native_language TEXT,
      foreign_language TEXT,
      avatar_config TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String createTestResults = '''
    CREATE TABLE test_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      completed_at TEXT NOT NULL,
      realistic REAL NOT NULL,
      investigative REAL NOT NULL,
      artistic REAL NOT NULL,
      social REAL NOT NULL,
      enterprising REAL NOT NULL,
      conventional REAL NOT NULL,
      holland_code TEXT NOT NULL,
      recommended_career_id TEXT,
      recommendation_percentage REAL
    )
  ''';

  static const String createAnswers = '''
    CREATE TABLE answers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      test_result_id INTEGER NOT NULL,
      question_id INTEGER NOT NULL,
      riasec_type TEXT NOT NULL,
      value INTEGER NOT NULL,
      FOREIGN KEY (test_result_id)
        REFERENCES test_results (id)
        ON DELETE CASCADE
    )
  ''';

  static const String createPreferences = '''
    CREATE TABLE preferences (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''';
}
