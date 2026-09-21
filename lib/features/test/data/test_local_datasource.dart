import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

class PersistedTestSession {
  final String id;
  final int currentIndex;
  final bool completed;
  final String openAnswer;
  final Map<int, double> answers;
  final List<int> questionOrder;

  const PersistedTestSession({
    required this.id,
    required this.currentIndex,
    required this.completed,
    required this.openAnswer,
    required this.answers,
    required this.questionOrder,
  });
}

class TestLocalDatasource {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<String?> getActiveSessionId() async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      Tables.metadata,
      where: 'key = ?',
      whereArgs: ['active_session_id'],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value']?.toString();
  }

  Future<void> setActiveSessionId(String id) async {
    final db = await _dbProvider.database;
    await db.insert(
      Tables.metadata,
      {'key': 'active_session_id', 'value': id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createSession({
    required String sessionId,
    required List<int> questionOrder,
  }) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.insert(
        Tables.sessions,
        {
          'id': sessionId,
          'started_at': DateTime.now().toIso8601String(),
          'completed_at': null,
          'current_index': 0,
          'question_order': questionOrder.join(','),
          'open_answer': '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        Tables.metadata,
        {'key': 'active_session_id', 'value': sessionId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<PersistedTestSession?> loadActiveSession() async {
    final id = await getActiveSessionId();
    if (id == null || id.isEmpty) return null;
    final db = await _dbProvider.database;
    final rows = await db.query(
      Tables.sessions,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final answerRows = await db.query(
      Tables.answers,
      where: 'session_id = ?',
      whereArgs: [id],
    );
    final answers = <int, double>{};
    for (final answer in answerRows) {
      final questionId = (answer['question_id'] as num?)?.toInt();
      final value = (answer['value'] as num?)?.toDouble();
      if (questionId != null && value != null) answers[questionId] = value;
    }
    return PersistedTestSession(
      id: id,
      currentIndex: (row['current_index'] as num?)?.toInt() ?? 0,
      completed: row['completed_at'] != null,
      openAnswer: row['open_answer']?.toString() ?? '',
      answers: answers,
      questionOrder: (row['question_order']?.toString() ?? '')
          .split(',')
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
    );
  }

  Future<void> saveAnswer({
    required String sessionId,
    required int questionId,
    required double value,
  }) async {
    final db = await _dbProvider.database;
    await db.delete(
      Tables.answers,
      where: 'session_id = ? AND question_id = ?',
      whereArgs: [sessionId, questionId],
    );
    await db.insert(Tables.answers, {
      'session_id': sessionId,
      'question_id': questionId,
      'value': value,
    });
  }

  Future<void> updateProgress({
    required String sessionId,
    required int currentIndex,
    String? openAnswer,
    bool completed = false,
  }) async {
    final db = await _dbProvider.database;
    await db.update(
      Tables.sessions,
      {
        'current_index': currentIndex,
        if (openAnswer != null) 'open_answer': openAnswer,
        if (completed) 'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }


  Future<void> saveCareerOpenAnswer({required String sessionId, required String careerId, required String questionText, required String answer}) async {
    final db = await _dbProvider.database;
    if (answer.trim().isEmpty) {
      await db.delete(Tables.careerOpenAnswers, where: 'session_id = ? AND career_id = ?', whereArgs: [sessionId, careerId]);
      return;
    }
    await db.insert(Tables.careerOpenAnswers, {'session_id': sessionId, 'career_id': careerId, 'question_text': questionText.trim(), 'answer': answer.trim()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, String>>> getCareerOpenAnswers(String sessionId) async {
    final db = await _dbProvider.database;
    final rows = await db.query(Tables.careerOpenAnswers, where: 'session_id = ?', whereArgs: [sessionId]);
    return rows.map((row) => {
      'career_id': row['career_id']?.toString() ?? '',
      'question_text': row['question_text']?.toString() ?? '',
      'answer': row['answer']?.toString() ?? '',
    }).toList();
  }
  Future<void> clearCurrentProgress() async {
    final id = await getActiveSessionId();
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      if (id != null && id.isNotEmpty) {
        // El historial depende de test_sessions porque test_results.session_id
        // usa ON DELETE CASCADE. Nunca eliminamos una sesión ya completada o
        // que tenga un resultado guardado; solo descartamos progreso incompleto.
        final completedRows = await txn.query(
          Tables.sessions,
          columns: ['completed_at'],
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        final resultRows = await txn.query(
          Tables.results,
          columns: ['id'],
          where: 'session_id = ?',
          whereArgs: [id],
          limit: 1,
        );
        final isCompleted = completedRows.isNotEmpty &&
            completedRows.first['completed_at'] != null;
        final hasSavedResult = resultRows.isNotEmpty;

        if (!isCompleted && !hasSavedResult) {
          await txn.delete(Tables.answers, where: 'session_id = ?', whereArgs: [id]);
          await txn.delete(Tables.careerOpenAnswers, where: 'session_id = ?', whereArgs: [id]);
          await txn.delete(Tables.sessions, where: 'id = ?', whereArgs: [id]);
        }
      }
      await txn.delete(
        Tables.metadata,
        where: 'key = ?',
        whereArgs: ['active_session_id'],
      );
    });
  }
}
