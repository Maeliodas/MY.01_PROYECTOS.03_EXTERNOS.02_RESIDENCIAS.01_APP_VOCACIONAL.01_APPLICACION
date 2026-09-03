abstract class DbTables {
  static const String userProfile = 'user_profile';
  static const String testSessions = 'test_sessions';
  static const String testAnswers = 'test_answers';
  static const String testResults = 'test_results';
  static const String syncQueue = 'sync_queue';
}

abstract class DbQueries {
  static const String createUserProfileTable = '''
    CREATE TABLE ${DbTables.userProfile} (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      gender TEXT NOT NULL,
      school TEXT NOT NULL,
      speaks_languages INTEGER NOT NULL, -- 0: No, 1: Sí
      languages_list TEXT, -- Almacenado como JSON/Comas
      avatar_config_json TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createTestSessionsTable = '''
    CREATE TABLE ${DbTables.testSessions} (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      status TEXT NOT NULL, -- 'in_progress', 'completed'
      question_order TEXT NOT NULL, -- JSON con el orden aleatorio de IDs
      current_index INTEGER NOT NULL DEFAULT 0,
      open_question_answer TEXT,
      created_at TEXT NOT NULL,
      completed_at TEXT,
      FOREIGN KEY (user_id) REFERENCES ${DbTables.userProfile} (id)
    );
  ''';

  static const String createTestAnswersTable = '''
    CREATE TABLE ${DbTables.testAnswers} (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      question_id INTEGER NOT NULL,
      dimension TEXT NOT NULL,
      value INTEGER NOT NULL, -- 0 a 9
      updated_at TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES ${DbTables.testSessions} (id)
    );
  ''';

  static const String createTestResultsTable = '''
    CREATE TABLE ${DbTables.testResults} (
      id TEXT PRIMARY KEY,
      session_id TEXT UNIQUE NOT NULL,
      score_r REAL NOT NULL,
      score_i REAL NOT NULL,
      score_a REAL NOT NULL,
      score_s REAL NOT NULL,
      score_e REAL NOT NULL,
      score_c REAL NOT NULL,
      holland_code TEXT NOT NULL,
      top_career_id TEXT NOT NULL,
      top_career_name TEXT NOT NULL,
      top_career_affinity REAL NOT NULL,
      full_ranking_json TEXT NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES ${DbTables.testSessions} (id)
    );
  ''';

  static const String createSyncQueueTable = '''
    CREATE TABLE ${DbTables.syncQueue} (
      id TEXT PRIMARY KEY,
      session_id TEXT UNIQUE NOT NULL,
      payload_json TEXT NOT NULL,
      attempts INTEGER NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'failed'
      created_at TEXT NOT NULL
    );
  ''';
}
