import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final root = await getDatabasesPath();

    _db = await openDatabase(
      join(root, 'user_data.db'),
      version: 4,
      onCreate: _create,
      onUpgrade: _upgrade,
    );

    return _db!;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Tables.profile}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,

        state TEXT NOT NULL DEFAULT 'No especificado',
        school TEXT NOT NULL DEFAULT 'No especificada',

        speaks_languages INTEGER NOT NULL DEFAULT 0,
        languages_list TEXT NOT NULL DEFAULT '',

        avatar_config_json TEXT NOT NULL DEFAULT '{}',

        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.profileLanguages}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        language_id TEXT,
        type TEXT NOT NULL,
        custom_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.avatar}(
        id INTEGER PRIMARY KEY CHECK(id = 1),
        base_avatar_id TEXT,
        hair_style TEXT,
        hair_color TEXT,
        outfit TEXT,
        accessory TEXT,
        skin_tone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.sessions}(
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        current_index INTEGER NOT NULL DEFAULT 0,
        question_order TEXT NOT NULL,
        open_answer TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.answers}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        value INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.results}(
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,

        score_r REAL NOT NULL DEFAULT 0,
        score_i REAL NOT NULL DEFAULT 0,
        score_a REAL NOT NULL DEFAULT 0,
        score_s REAL NOT NULL DEFAULT 0,
        score_e REAL NOT NULL DEFAULT 0,
        score_c REAL NOT NULL DEFAULT 0,

        holland_code TEXT NOT NULL,

        top_career_id TEXT NOT NULL DEFAULT '',
        top_career_name TEXT NOT NULL DEFAULT '',
        top_career_affinity REAL NOT NULL DEFAULT 0,

        full_ranking_json TEXT NOT NULL DEFAULT '[]',

        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.metadata}(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.syncQueue}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN speaks_foreign_language
        INTEGER NOT NULL DEFAULT 0
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN state
        TEXT NOT NULL DEFAULT 'No especificado'
      ''');

      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN school
        TEXT NOT NULL DEFAULT 'No especificada'
      ''');

      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN speaks_languages
        INTEGER NOT NULL DEFAULT 0
      ''');

      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN languages_list
        TEXT NOT NULL DEFAULT ''
      ''');

      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN avatar_config_json
        TEXT NOT NULL DEFAULT '{}'
      ''');

      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN created_at
        TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'
      ''');

      await db.execute('''
        ALTER TABLE ${Tables.profile}
        ADD COLUMN updated_at
        TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'
      ''');

      // Reservado para una futura activación del municipio/localidad.
      //
      // await db.execute('''
      //   ALTER TABLE ${Tables.profile}
      //   ADD COLUMN municipality_id
      //   TEXT
      // ''');
    }

    if (oldVersion < 4) {
      await db.execute(
        'DROP TABLE IF EXISTS ${Tables.results}',
      );

      await db.execute('''
        CREATE TABLE ${Tables.results}(
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,

          score_r REAL NOT NULL DEFAULT 0,
          score_i REAL NOT NULL DEFAULT 0,
          score_a REAL NOT NULL DEFAULT 0,
          score_s REAL NOT NULL DEFAULT 0,
          score_e REAL NOT NULL DEFAULT 0,
          score_c REAL NOT NULL DEFAULT 0,

          holland_code TEXT NOT NULL,

          top_career_id TEXT NOT NULL DEFAULT '',
          top_career_name TEXT NOT NULL DEFAULT '',
          top_career_affinity REAL NOT NULL DEFAULT 0,

          full_ranking_json TEXT NOT NULL DEFAULT '[]',

          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }
}
