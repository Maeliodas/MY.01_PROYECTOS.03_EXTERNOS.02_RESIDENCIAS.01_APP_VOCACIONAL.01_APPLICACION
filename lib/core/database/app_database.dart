import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/careers_data.dart';
import 'tables.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      join(root, 'aevum_iter.db'),
      version: 2,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    return _db!;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('CREATE TABLE ${Tables.schools}(id TEXT PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE ${Tables.languages}(id TEXT PRIMARY KEY, name TEXT NOT NULL, type TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1)');
    await db.execute('CREATE TABLE ${Tables.careers}(id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT, holland_codes TEXT)');
    await db.execute('CREATE TABLE ${Tables.profile}(id INTEGER PRIMARY KEY CHECK(id=1), name TEXT, age INTEGER, gender TEXT, school_id TEXT, speaks_mother_tongue INTEGER NOT NULL DEFAULT 0, speaks_foreign_language INTEGER NOT NULL DEFAULT 0)');
    await db.execute('CREATE TABLE ${Tables.profileLanguages}(id INTEGER PRIMARY KEY AUTOINCREMENT, language_id TEXT, type TEXT NOT NULL, custom_name TEXT)');
    await db.execute('CREATE TABLE ${Tables.avatar}(id INTEGER PRIMARY KEY CHECK(id=1), base_avatar_id TEXT, hair_style TEXT, hair_color TEXT, outfit TEXT, accessory TEXT, skin_tone TEXT)');
    await db.execute('CREATE TABLE ${Tables.sessions}(id TEXT PRIMARY KEY, started_at TEXT NOT NULL, completed_at TEXT, current_index INTEGER NOT NULL DEFAULT 0, question_order TEXT NOT NULL, open_answer TEXT)');
    await db.execute('CREATE TABLE ${Tables.answers}(id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT NOT NULL, question_id TEXT NOT NULL, value INTEGER NOT NULL)');
    await db.execute('CREATE TABLE ${Tables.results}(id TEXT PRIMARY KEY, session_id TEXT NOT NULL, created_at TEXT NOT NULL, scores_json TEXT NOT NULL, holland_code TEXT NOT NULL, recommended_careers_json TEXT NOT NULL)');
    await db.execute('CREATE TABLE ${Tables.metadata}(key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('CREATE TABLE ${Tables.syncQueue}(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, payload TEXT NOT NULL, created_at TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0)');
    await _seed(db);
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${Tables.profile} ADD COLUMN speaks_foreign_language INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> _seed(Database db) async {
    final schools = ['Instituto Tecnológico de Tuxtepec', 'CBTis', 'COBAO', 'CECyTE', 'Preparatoria General', 'Otra'];
    for (final name in schools) {
      await db.insert(Tables.schools, {'id': name.toLowerCase().replaceAll(' ', '_'), 'name': name});
    }
    final mother = ['Chinanteco', 'Mazateco', 'Zapoteco', 'Mixe', 'Mixteco'];
    final foreign = ['Inglés', 'Francés', 'Portugués', 'Alemán', 'Italiano'];
    for (final name in mother) {
      await db.insert(Tables.languages, {'id': 'mother_${name.toLowerCase()}', 'name': name, 'type': 'mother'});
    }
    for (final name in foreign) {
      await db.insert(Tables.languages, {'id': 'foreign_${name.toLowerCase()}', 'name': name, 'type': 'foreign'});
    }
    for (final career in CareersData.initialCareers) {
      await db.insert(Tables.careers, career);
    }
  }
}
