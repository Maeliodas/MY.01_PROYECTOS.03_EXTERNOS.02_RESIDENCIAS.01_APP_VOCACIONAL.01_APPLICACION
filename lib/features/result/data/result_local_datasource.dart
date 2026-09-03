import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

class ResultLocalDatasource {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveResult({
    required String sessionId,
    required double scoreR,
    required double scoreI,
    required double scoreA,
    required double scoreS,
    required double scoreE,
    required double scoreC,
    required String hollandCode,
    required String topCareerId,
    required String topCareerName,
    required double topCareerAffinity,
    required List<Map<String, dynamic>> fullRanking,
  }) async {
    final db = await _dbProvider.database;
    await db.insert(
      DbTables.testResults,
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'session_id': sessionId,
        'score_r': scoreR,
        'score_i': scoreI,
        'score_a': scoreA,
        'score_s': scoreS,
        'score_e': scoreE,
        'score_c': scoreC,
        'holland_code': hollandCode,
        'top_career_id': topCareerId,
        'top_career_name': topCareerName,
        'top_career_affinity': topCareerAffinity,
        'full_ranking_json': jsonEncode(fullRanking),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLatestResult() async {
    final db = await _dbProvider.database;
    final results = await db.query(
      DbTables.testResults,
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
