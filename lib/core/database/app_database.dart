import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_seed.dart';
import 'tables.dart';

class AppDatabase {
  AppDatabase._();

  static final instance = AppDatabase._();
  static const databaseVersion = 16;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      join(root, 'app_vocacional_ittux.db'),
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
        name TEXT NOT NULL UNIQUE,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.municipalities}(
        id TEXT PRIMARY KEY,
        state_id TEXT NOT NULL,
        name TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(state_id) REFERENCES ${Tables.states}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.schools}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        municipality_id TEXT,
        type TEXT,
        active INTEGER NOT NULL DEFAULT 1,
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
        related_career_id TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(related_career_id) REFERENCES ${Tables.careers}(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.careers}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        holland_code TEXT NOT NULL,
        department TEXT NOT NULL,
        website_url TEXT,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.departmentQuestions}(
        department TEXT PRIMARY KEY,
        question_text TEXT NOT NULL,
        updated_at TEXT
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
      CREATE TABLE ${Tables.catalogSuggestionQueue}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT NOT NULL,
        name TEXT NOT NULL,
        municipality_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(municipality_id) REFERENCES ${Tables.municipalities}(id),
        UNIQUE(kind, name, municipality_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.profile}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        school_id TEXT,
        pending_school_suggestion_id INTEGER,
        speaks_languages INTEGER NOT NULL DEFAULT 0,
        languages_list TEXT NOT NULL DEFAULT '',
        avatar_config_json TEXT NOT NULL DEFAULT '{}',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(school_id) REFERENCES ${Tables.schools}(id),
        FOREIGN KEY(pending_school_suggestion_id) REFERENCES ${Tables.catalogSuggestionQueue}(id)
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
    await db.execute('''
      CREATE TABLE ${Tables.answers}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        question_id INTEGER NOT NULL,
        value REAL NOT NULL,
        FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE,
        FOREIGN KEY(question_id) REFERENCES ${Tables.questions}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.careerOpenAnswers}(
        session_id TEXT NOT NULL,
        career_id TEXT NOT NULL,
        question_text TEXT NOT NULL DEFAULT '',
        answer TEXT NOT NULL,
        PRIMARY KEY(session_id, career_id),
        FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE,
        FOREIGN KEY(career_id) REFERENCES ${Tables.careers}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${Tables.results}(
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL UNIQUE,
        score_r REAL NOT NULL DEFAULT 0, score_i REAL NOT NULL DEFAULT 0,
        score_a REAL NOT NULL DEFAULT 0, score_s REAL NOT NULL DEFAULT 0,
        score_e REAL NOT NULL DEFAULT 0, score_c REAL NOT NULL DEFAULT 0,
        holland_code TEXT NOT NULL,
        top_career_id TEXT NOT NULL DEFAULT '',
        top_career_name TEXT NOT NULL DEFAULT '',
        top_career_affinity REAL NOT NULL DEFAULT 0,
        full_ranking_json TEXT NOT NULL DEFAULT '[]',
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE,
        FOREIGN KEY(top_career_id) REFERENCES ${Tables.careers}(id)
      )
    ''');
    await db.execute('CREATE TABLE ${Tables.metadata}(key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('''
      CREATE TABLE ${Tables.syncQueue}(
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE
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
    if (oldVersion < 8) {
      await db.transaction((txn) async {
        await txn.delete(Tables.profileLanguages);
        await txn.delete(Tables.languages);
        await DatabaseSeed.apply(txn);
      });
    }
    if (oldVersion < 9) {
      await db.transaction((txn) async {
        final stateCols = await txn.rawQuery('PRAGMA table_info(${Tables.states})');
        if (!stateCols.any((row) => row['name'] == 'active')) {
          await txn.execute('ALTER TABLE ${Tables.states} ADD COLUMN active INTEGER NOT NULL DEFAULT 1');
        }
        final municipalityCols = await txn.rawQuery('PRAGMA table_info(${Tables.municipalities})');
        if (!municipalityCols.any((row) => row['name'] == 'active')) {
          await txn.execute('ALTER TABLE ${Tables.municipalities} ADD COLUMN active INTEGER NOT NULL DEFAULT 1');
        }
        await DatabaseSeed.apply(txn);
      });
    }


    if (oldVersion < 10) {
      final careerColumns = await db.rawQuery('PRAGMA table_info(${Tables.careers})');
      final names = careerColumns.map((e) => e['name']?.toString()).toSet();
      if (!names.contains('website_url')) await db.execute('ALTER TABLE ${Tables.careers} ADD COLUMN website_url TEXT');
      if (!names.contains('open_question')) await db.execute('ALTER TABLE ${Tables.careers} ADD COLUMN open_question TEXT');
      await db.execute('CREATE TABLE IF NOT EXISTS ${Tables.careerOpenAnswers}(session_id TEXT NOT NULL, career_id TEXT NOT NULL, answer TEXT NOT NULL, PRIMARY KEY(session_id, career_id))');
      await DatabaseSeed.apply(db);
    }

    if (oldVersion < 11) {
      final questionColumns = await db.rawQuery('PRAGMA table_info(${Tables.questions})');
      final qNames = questionColumns.map((e) => e['name']?.toString()).toSet();
      if (!qNames.contains('related_career_id')) {
        await db.execute('ALTER TABLE ${Tables.questions} ADD COLUMN related_career_id TEXT');
      }
      await DatabaseSeed.apply(db);
    }

    if (oldVersion < 12) {
      final openColumns = await db.rawQuery('PRAGMA table_info(${Tables.careerOpenAnswers})');
      final openNames = openColumns.map((e) => e['name']?.toString()).toSet();
      if (!openNames.contains('question_text')) {
        await db.execute("ALTER TABLE ${Tables.careerOpenAnswers} ADD COLUMN question_text TEXT NOT NULL DEFAULT ''");
      }
    }

    if (oldVersion < 13) {
      final careerColumns = await db.rawQuery('PRAGMA table_info(${Tables.careers})');
      final careerNames = careerColumns.map((e) => e['name']?.toString()).toSet();
      if (!careerNames.contains('department')) {
        await db.execute("ALTER TABLE ${Tables.careers} ADD COLUMN department TEXT NOT NULL DEFAULT 'Sistemas y Computación'");
      }
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.departmentQuestions}(
          department TEXT PRIMARY KEY,
          question_text TEXT NOT NULL,
          updated_at TEXT
        )
      ''');
      await DatabaseSeed.apply(db);
    }

    if (oldVersion < 14) {
      // SQLite no permite agregar FOREIGN KEY con ALTER TABLE. Se reconstruyen
      // las tablas operativas para que herramientas de ingeniería inversa
      // (por ejemplo DBeaver) detecten las relaciones físicas reales.
      await db.transaction((txn) async {

        Future<void> rebuild(String table, String createSql, List<String> columns) async {
          final old = '${table}_v13';
          await txn.execute('ALTER TABLE $table RENAME TO $old');
          await txn.execute(createSql);
          final cols = columns.join(', ');
          await txn.execute('INSERT INTO $table ($cols) SELECT $cols FROM $old');
          await txn.execute('DROP TABLE $old');
        }

        await rebuild(Tables.answers, '''
          CREATE TABLE ${Tables.answers}(
            id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT NOT NULL,
            question_id INTEGER NOT NULL, value REAL NOT NULL,
            FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE,
            FOREIGN KEY(question_id) REFERENCES ${Tables.questions}(id)
          )
        ''', ['id','session_id','question_id','value']);

        await rebuild(Tables.careerOpenAnswers, '''
          CREATE TABLE ${Tables.careerOpenAnswers}(
            session_id TEXT NOT NULL, career_id TEXT NOT NULL,
            question_text TEXT NOT NULL DEFAULT '', answer TEXT NOT NULL,
            PRIMARY KEY(session_id, career_id),
            FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE,
            FOREIGN KEY(career_id) REFERENCES ${Tables.careers}(id)
          )
        ''', ['session_id','career_id','question_text','answer']);

        await rebuild(Tables.results, '''
          CREATE TABLE ${Tables.results}(
            id TEXT PRIMARY KEY, session_id TEXT NOT NULL UNIQUE,
            score_r REAL NOT NULL DEFAULT 0, score_i REAL NOT NULL DEFAULT 0,
            score_a REAL NOT NULL DEFAULT 0, score_s REAL NOT NULL DEFAULT 0,
            score_e REAL NOT NULL DEFAULT 0, score_c REAL NOT NULL DEFAULT 0,
            holland_code TEXT NOT NULL, top_career_id TEXT NOT NULL DEFAULT '',
            top_career_name TEXT NOT NULL DEFAULT '', top_career_affinity REAL NOT NULL DEFAULT 0,
            full_ranking_json TEXT NOT NULL DEFAULT '[]', is_synced INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE,
            FOREIGN KEY(top_career_id) REFERENCES ${Tables.careers}(id)
          )
        ''', ['id','session_id','score_r','score_i','score_a','score_s','score_e','score_c','holland_code','top_career_id','top_career_name','top_career_affinity','full_ranking_json','is_synced','created_at']);

        await rebuild(Tables.syncQueue, '''
          CREATE TABLE ${Tables.syncQueue}(
            id TEXT PRIMARY KEY, session_id TEXT NOT NULL, payload_json TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'pending',
            created_at TEXT NOT NULL,
            FOREIGN KEY(session_id) REFERENCES ${Tables.sessions}(id) ON DELETE CASCADE
          )
        ''', ['id','session_id','payload_json','attempts','status','created_at']);

      });
    }

    if (oldVersion < 15) {
      // Normalización geográfica: una escuela obtiene su estado a través de
      // municipality_id -> municipalities.state_id. Se elimina schools.state_id
      // para evitar almacenar dos veces la misma dependencia funcional.
      await db.transaction((txn) async {
        await txn.execute('ALTER TABLE ${Tables.profileLanguages} RENAME TO user_languages_v14');
        await txn.execute('ALTER TABLE ${Tables.profile} RENAME TO user_profile_v14');
        await txn.execute('ALTER TABLE ${Tables.schools} RENAME TO schools_v14');

        await txn.execute('''
          CREATE TABLE ${Tables.schools}(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            municipality_id TEXT,
            type TEXT,
            active INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY(municipality_id) REFERENCES ${Tables.municipalities}(id)
          )
        ''');
        await txn.execute('''
          INSERT INTO ${Tables.schools}(id,name,municipality_id,type,active)
          SELECT id,name,municipality_id,type,active FROM schools_v14
        ''');

        await txn.execute('''
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
        await txn.execute('''
          INSERT INTO ${Tables.profile}(
            id,name,age,gender,state_id,state,municipality_id,municipality,
            school_id,school,speaks_languages,languages_list,avatar_config_json,
            created_at,updated_at
          )
          SELECT id,name,age,gender,state_id,state,municipality_id,municipality,
            school_id,school,speaks_languages,languages_list,avatar_config_json,
            created_at,updated_at
          FROM user_profile_v14
        ''');

        await txn.execute('''
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
        await txn.execute('''
          INSERT INTO ${Tables.profileLanguages}(id,profile_id,language_id,type,custom_name)
          SELECT id,profile_id,language_id,type,custom_name FROM user_languages_v14
        ''');

        await txn.execute('DROP TABLE user_languages_v14');
        await txn.execute('DROP TABLE user_profile_v14');
        await txn.execute('DROP TABLE schools_v14');
      });
    }

    if (oldVersion < 16) {
      await db.transaction((txn) async {
        // La cola ahora también soporta sugerencias de escuelas por municipio.
        await txn.execute('ALTER TABLE ${Tables.catalogSuggestionQueue} RENAME TO catalog_suggestion_queue_v15');
        await txn.execute('''
          CREATE TABLE ${Tables.catalogSuggestionQueue}(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kind TEXT NOT NULL,
            name TEXT NOT NULL,
            municipality_id TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY(municipality_id) REFERENCES ${Tables.municipalities}(id),
            UNIQUE(kind, name, municipality_id)
          )
        ''');
        await txn.execute('''
          INSERT INTO ${Tables.catalogSuggestionQueue}(id,kind,name,created_at)
          SELECT id,kind,name,created_at FROM catalog_suggestion_queue_v15
        ''');

        await txn.execute('ALTER TABLE ${Tables.profileLanguages} RENAME TO user_languages_v15');
        await txn.execute('ALTER TABLE ${Tables.profile} RENAME TO user_profile_v15');
        await txn.execute('''
          CREATE TABLE ${Tables.profile}(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            school_id TEXT,
            pending_school_suggestion_id INTEGER,
            speaks_languages INTEGER NOT NULL DEFAULT 0,
            languages_list TEXT NOT NULL DEFAULT '',
            avatar_config_json TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(school_id) REFERENCES ${Tables.schools}(id),
            FOREIGN KEY(pending_school_suggestion_id) REFERENCES ${Tables.catalogSuggestionQueue}(id)
          )
        ''');
        await txn.execute('''
          INSERT OR IGNORE INTO ${Tables.catalogSuggestionQueue}(kind,name,municipality_id,created_at)
          SELECT 'escuela', school, municipality_id, updated_at
          FROM user_profile_v15
          WHERE municipality_id IS NOT NULL
            AND (school_id IS NULL OR school_id IN (SELECT id FROM ${Tables.schools} WHERE municipality_id IS NULL))
            AND TRIM(school) <> '' AND LOWER(TRIM(school)) NOT IN ('otra escuela','no especificada')
        ''');
        await txn.execute('''
          INSERT INTO ${Tables.profile}(
            id,name,age,gender,school_id,pending_school_suggestion_id,speaks_languages,languages_list,
            avatar_config_json,created_at,updated_at
          )
          SELECT p.id,p.name,p.age,p.gender,
            CASE WHEN p.school_id IN (SELECT id FROM ${Tables.schools} WHERE municipality_id IS NOT NULL) THEN p.school_id ELSE NULL END,
            (SELECT q.id FROM ${Tables.catalogSuggestionQueue} q
              WHERE q.kind='escuela' AND q.name=p.school AND q.municipality_id=p.municipality_id LIMIT 1),
            p.speaks_languages,p.languages_list,p.avatar_config_json,p.created_at,p.updated_at
          FROM user_profile_v15 p
        ''');
        await txn.execute('''
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
        await txn.execute('''
          INSERT INTO ${Tables.profileLanguages}(id,profile_id,language_id,type,custom_name)
          SELECT id,profile_id,language_id,type,custom_name FROM user_languages_v15
        ''');
        await txn.execute('DROP TABLE user_languages_v15');
        await txn.execute('DROP TABLE user_profile_v15');
        await txn.execute('DROP TABLE catalog_suggestion_queue_v15');
      });
    }

  }
}
