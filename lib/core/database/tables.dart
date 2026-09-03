abstract class Tables {
  static const String userProfile = 'user_profile';
  static const String testSessions = 'test_sessions';
  static const String testAnswers = 'test_answers';
  static const String testResults = 'test_results';
  static const String syncQueue = 'sync_queue';

  static const String createUserProfileTable = '''
    CREATE TABLE $userProfile (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      gender TEXT NOT NULL,
      school TEXT NOT NULL,
      language TEXT NOT NULL,
      avatar_config TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createTestSessionsTable = '''
    CREATE TABLE $testSessions (
      id TEXT PRIMARY KEY,
      status TEXT NOT NULL, -- 'in_progress', 'completed'
      current_index INTEGER NOT NULL DEFAULT 0,
      question_order TEXT NOT NULL, -- JSON String
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createTestAnswersTable = '''
    CREATE TABLE $testAnswers (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      question_id INTEGER NOT NULL,
      value INTEGER NOT NULL,
      dimension TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES $testSessions (id) ON DELETE CASCADE
    );
  ''';

  static const String createTestResultsTable = '''
    CREATE TABLE $testResults (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      scores_json TEXT NOT NULL,
      holland_code TEXT NOT NULL,
      top_career_id TEXT NOT NULL,
      top_careers_json TEXT NOT NULL,
      open_question_response TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES $testSessions (id) ON DELETE CASCADE
    );
  ''';

  static const String createSyncQueueTable = '''
    CREATE TABLE $syncQueue (
      id TEXT PRIMARY KEY,
      payload_json TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'synced'
      created_at TEXT NOT NULL
    );
  ''';
}
