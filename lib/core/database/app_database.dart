import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'tables.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(databasesPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: (database, version) async {
        await database.execute(DatabaseSchema.createUserProfile);

        await database.execute(DatabaseSchema.createTestResults);

        await database.execute(DatabaseSchema.createAnswers);

        await database.execute(DatabaseSchema.createPreferences);
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
