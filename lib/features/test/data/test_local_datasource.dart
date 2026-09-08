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

    await db.insert(Tables.answers, {
      'id': '${sessionId}_$questionId',
      'session_id': sessionId,
      'question_id': questionId,
      'dimension': dimension,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<int, int>> getAnswersForSession(String sessionId) async {
    final db = await _dbProvider.database;

    final results = await db.query(
      Tables.answers,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    final Map<int, int> answers = {};

    for (final row in results) {
      final questionId = row['question_id'];
      final value = row['value'];

      if (questionId is int && value is int) {
        answers[questionId] = value;
      }
    }

    return answers;
  }
}
