import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import 'tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(Tables.createUserProfileTable);
    await db.execute(Tables.createTestSessionsTable);
    await db.execute(Tables.createTestAnswersTable);
    await db.execute(Tables.createTestResultsTable);
    await db.execute(Tables.createSyncQueueTable);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
