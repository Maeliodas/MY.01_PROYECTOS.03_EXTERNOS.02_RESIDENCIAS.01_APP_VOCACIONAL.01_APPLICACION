import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_seed.dart';
import 'tables.dart';

class AppDatabase {
  AppDatabase._();

  static final instance = AppDatabase._();
  static const databaseVersion = 7;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      join(root, 'aevum_iter.db'),
      version: databaseVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    return _db!;
  }

  Future<void> _create(Database db, int version) async {
    await _createCatalogTables(db);
    await _createOperationalTables(db);
    await DatabaseSeed.apply(db);
  }

  Future<void> _createCatalogTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${Tables.states}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.municipalities}(
        id TEXT PRIMARY KEY,
        state_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(state_id) REFERENCES ${Tables.states}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.schools}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        state_id TEXT,
        municipality_id TEXT,
        type TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(state_id) REFERENCES ${Tables.states}(id),
        FOREIGN KEY(municipality_id) REFERENCES ${Tables.municipalities}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.languages}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.questions}(
        id INTEGER PRIMARY KEY,
        text TEXT NOT NULL,
        dimension TEXT NOT NULL,
        position INTEGER NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.careers}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        holland_code TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.careerWeights}(
        career_id TEXT NOT NULL,
        dimension TEXT NOT NULL,
        weight REAL NOT NULL,
        PRIMARY KEY(career_id, dimension),
        FOREIGN KEY(career_id) REFERENCES ${Tables.careers}(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.careerQuestions}(
        career_id TEXT NOT NULL,
        question_id INTEGER NOT NULL,
        PRIMARY KEY(career_id, question_id),
        FOREIGN KEY(career_id) REFERENCES ${Tables.careers}(id) ON DELETE CASCADE,
        FOREIGN KEY(question_id) REFERENCES ${Tables.questions}(id)
      )
    ''');
  }

  Future<void> _createOperationalTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${Tables.profile}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        state_id TEXT,
        state TEXT NOT NULL DEFAULT 'No especificado',
        municipality_id TEXT,
        municipality TEXT NOT NULL DEFAULT 'No especificado',
        school_id TEXT,
        school TEXT NOT NULL DEFAULT 'No especificada',
        speaks_languages INTEGER NOT NULL DEFAULT 0,
        languages_list TEXT NOT NULL DEFAULT '',
        avatar_config_json TEXT NOT NULL DEFAULT '{}',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(state_id) REFERENCES ${Tables.states}(id),
        FOREIGN KEY(municipality_id) REFERENCES ${Tables.municipalities}(id),
        FOREIGN KEY(school_id) REFERENCES ${Tables.schools}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.profileLanguages}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id TEXT NOT NULL DEFAULT '1',
        language_id TEXT,
        type TEXT NOT NULL,
        custom_name TEXT,
        FOREIGN KEY(profile_id) REFERENCES ${Tables.profile}(id) ON DELETE CASCADE,
        FOREIGN KEY(language_id) REFERENCES ${Tables.languages}(id)
      )
    ''');
    await db.execute('CREATE TABLE ${Tables.avatar}(id INTEGER PRIMARY KEY CHECK(id=1), base_avatar_id TEXT, hair_style TEXT, hair_color TEXT, outfit TEXT, accessory TEXT, skin_tone TEXT)');
    await db.execute('CREATE TABLE ${Tables.sessions}(id TEXT PRIMARY KEY, started_at TEXT NOT NULL, completed_at TEXT, current_index INTEGER NOT NULL DEFAULT 0, question_order TEXT NOT NULL, open_answer TEXT)');
    await db.execute('CREATE TABLE ${Tables.answers}(id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT NOT NULL, question_id INTEGER NOT NULL, value REAL NOT NULL)');
    await db.execute("CREATE TABLE ${Tables.results}(id TEXT PRIMARY KEY, session_id TEXT NOT NULL, score_r REAL NOT NULL DEFAULT 0, score_i REAL NOT NULL DEFAULT 0, score_a REAL NOT NULL DEFAULT 0, score_s REAL NOT NULL DEFAULT 0, score_e REAL NOT NULL DEFAULT 0, score_c REAL NOT NULL DEFAULT 0, holland_code TEXT NOT NULL, top_career_id TEXT NOT NULL DEFAULT '', top_career_name TEXT NOT NULL DEFAULT '', top_career_affinity REAL NOT NULL DEFAULT 0, full_ranking_json TEXT NOT NULL DEFAULT '[]', is_synced INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL)");
    await db.execute('CREATE TABLE ${Tables.metadata}(key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('''
      CREATE TABLE ${Tables.syncQueue}(
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.transaction((txn) async {
        await txn.execute('DROP TABLE IF EXISTS ${Tables.careerQuestions}');
        await txn.execute('DROP TABLE IF EXISTS ${Tables.careerWeights}');
        await txn.execute('DROP TABLE IF EXISTS ${Tables.questions}');
        await txn.execute('DROP TABLE IF EXISTS ${Tables.municipalities}');
        await txn.execute('DROP TABLE IF EXISTS ${Tables.states}');

        // Recreate catalog tables; schools/languages/careers are migrated in place.
        await txn.execute('CREATE TABLE ${Tables.states}(id TEXT PRIMARY KEY, name TEXT NOT NULL UNIQUE)');
        await txn.execute('CREATE TABLE ${Tables.municipalities}(id TEXT PRIMARY KEY, state_id TEXT NOT NULL, name TEXT NOT NULL)');
        await txn.execute('CREATE TABLE ${Tables.questions}(id INTEGER PRIMARY KEY, text TEXT NOT NULL, dimension TEXT NOT NULL, position INTEGER NOT NULL, active INTEGER NOT NULL DEFAULT 1)');
        await txn.execute('CREATE TABLE ${Tables.careerWeights}(career_id TEXT NOT NULL, dimension TEXT NOT NULL, weight REAL NOT NULL, PRIMARY KEY(career_id, dimension))');
        await txn.execute('CREATE TABLE ${Tables.careerQuestions}(career_id TEXT NOT NULL, question_id INTEGER NOT NULL, PRIMARY KEY(career_id, question_id))');

        // Normalize existing catalogs by recreating them with relational columns.
        await txn.execute('ALTER TABLE ${Tables.schools} RENAME TO schools_legacy');
        await txn.execute('CREATE TABLE ${Tables.schools}(id TEXT PRIMARY KEY, name TEXT NOT NULL, state_id TEXT, municipality_id TEXT, type TEXT, active INTEGER NOT NULL DEFAULT 1)');
        await txn.execute('DROP TABLE schools_legacy');

        await txn.execute('ALTER TABLE ${Tables.careers} RENAME TO careers_legacy');
        await txn.execute('CREATE TABLE ${Tables.careers}(id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT, holland_code TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1)');
        await txn.execute('DROP TABLE careers_legacy');

        final profileColumns = await txn.rawQuery('PRAGMA table_info(${Tables.profile})');
        final names = profileColumns.map((e) => e['name']?.toString()).toSet();
        if (!names.contains('state_id')) await txn.execute('ALTER TABLE ${Tables.profile} ADD COLUMN state_id TEXT');
        if (!names.contains('municipality_id')) await txn.execute('ALTER TABLE ${Tables.profile} ADD COLUMN municipality_id TEXT');
        if (!names.contains('municipality')) await txn.execute("ALTER TABLE ${Tables.profile} ADD COLUMN municipality TEXT NOT NULL DEFAULT 'No especificado'");
        if (!names.contains('school_id')) await txn.execute('ALTER TABLE ${Tables.profile} ADD COLUMN school_id TEXT');

        await txn.execute('DROP TABLE IF EXISTS ${Tables.profileLanguages}');
        await txn.execute("CREATE TABLE ${Tables.profileLanguages}(id INTEGER PRIMARY KEY AUTOINCREMENT, profile_id TEXT NOT NULL DEFAULT '1', language_id TEXT, type TEXT NOT NULL, custom_name TEXT)");

        await txn.execute('DROP TABLE IF EXISTS ${Tables.syncQueue}');
        await txn.execute("CREATE TABLE ${Tables.syncQueue}(id TEXT PRIMARY KEY, session_id TEXT NOT NULL, payload_json TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'pending', created_at TEXT NOT NULL)");

        await DatabaseSeed.apply(txn);
      });
    }

    if (oldVersion < 6) {
      await db.transaction((txn) async {
        // Catálogos institucionales: se eliminan restos de sincronización externa
        // y se reemplaza el catálogo de lenguas por la lista oficial del proyecto.
        await txn.delete(Tables.profileLanguages);
        await txn.delete(Tables.languages);
        await txn.delete(
          Tables.metadata,
          where: 'key LIKE ?',
          whereArgs: ['municipalities_synced_%'],
        );
        await DatabaseSeed.apply(txn);
      });
    }

    if (oldVersion < 7) {
      await db.transaction((txn) async {
        // Catálogo temporal basado en los valores que existían antes
        // directamente en la interfaz. No se consulta ninguna API externa.
        // Se mantienen los municipios locales disponibles y se normaliza
        // la lista de preparatorias de procedencia.
        await DatabaseSeed.apply(txn);

        // El Tecnológico se había agregado como escuela de procedencia en una
        // versión intermedia, pero no formaba parte de la lista hard-coded
        // original de preparatorias. Se desactiva sin romper perfiles previos.
        await txn.update(
          Tables.schools,
          {'active': 0},
          where: 'id = ?',
          whereArgs: ['tecnm_tuxtepec'],
        );
      });
    }
  }
}
