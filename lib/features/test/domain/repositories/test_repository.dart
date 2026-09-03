import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../models/test_session.dart';

class TestRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveSession(TestSession session) async {
    final db = await _dbProvider.database;
    await db.insert(
      DbTables.testSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TestSession?> getActiveSession(String userId) async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DbTables.testSessions,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'in_progress'],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      return TestSession.fromMap(results.first);
    }
    return null;
  }
}
