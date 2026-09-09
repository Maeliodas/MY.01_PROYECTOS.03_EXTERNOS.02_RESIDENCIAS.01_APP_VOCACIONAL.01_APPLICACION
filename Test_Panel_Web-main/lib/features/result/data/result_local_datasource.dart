import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

class ResultLocalDatasource {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<String> saveResult({
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
    final resultId = DateTime.now().microsecondsSinceEpoch.toString();
    await db.insert(
      Tables.results,
      {
        'id': resultId,
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
    return resultId;
  }

  Future<void> markSynced(String resultId) async {
    final db = await _dbProvider.database;
    await db.update(
      Tables.results,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [resultId],
    );
  }

  Future<Map<String, dynamic>?> getLatestResult() async {
    final db = await _dbProvider.database;
    final results = await db.query(
      Tables.results,
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<List<Map<String, dynamic>>> getAllResults() async {
    final db = await _dbProvider.database;
    return db.query(Tables.results, orderBy: 'created_at DESC');
  }
}

final resultDatasourceProvider = Provider<ResultLocalDatasource>((ref) {
  return ResultLocalDatasource();
});
