import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_vocacional.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DbQueries.createUserProfileTable);
    await db.execute(DbQueries.createTestSessionsTable);
    await db.execute(DbQueries.createTestAnswersTable);
    await db.execute(DbQueries.createTestResultsTable);
    await db.execute(DbQueries.createSyncQueueTable);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
