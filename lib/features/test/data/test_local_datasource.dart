import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

class TestLocalDatasource {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveAnswer({
    required String sessionId,
    required int questionId,
    required String dimension,
    required int value,
  }) async {
    final db = await _dbProvider.database;
    await db.insert(
      DbTables.testAnswers,
      {
        'id': '${sessionId}_$questionId',
        'session_id': sessionId,
        'question_id': questionId,
        'dimension': dimension,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, int>> getAnswersForSession(String sessionId) async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DbTables.testAnswers,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    final Map<int, int> answers = {};
    for (final row in results) {
      answers[row['question_id'] as int] = row['value'] as int;
    }
    return answers;
  }
}
