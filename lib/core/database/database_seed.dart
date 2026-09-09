import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

class DatabaseSeed {
  const DatabaseSeed._();

  static const _asset = 'assets/database/seed_catalog_v7.json';

  static Future<void> apply(DatabaseExecutor db) async {
    final raw = await rootBundle.loadString(_asset);
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final batch = db.batch();

    for (final row in (data['states'] as List<dynamic>)) {
      final item = Map<String, dynamic>.from(row as Map);
      batch.insert(Tables.states, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final row in (data['municipalities'] as List<dynamic>)) {
      final item = Map<String, dynamic>.from(row as Map);
      batch.insert(Tables.municipalities, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final row in (data['schools'] as List<dynamic>)) {
      final item = Map<String, dynamic>.from(row as Map);
      batch.insert(Tables.schools, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final row in (data['languages'] as List<dynamic>)) {
      final item = Map<String, dynamic>.from(row as Map);
      batch.insert(Tables.languages, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final row in (data['questions'] as List<dynamic>)) {
      final item = Map<String, dynamic>.from(row as Map);
      batch.insert(Tables.questions, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final row in (data['careers'] as List<dynamic>)) {
      final item = Map<String, dynamic>.from(row as Map);
      final weights = Map<String, dynamic>.from(item.remove('weights') as Map);
      final questionIds = List<dynamic>.from(item.remove('question_ids') as List);
      batch.insert(Tables.careers, item,
          conflictAlgorithm: ConflictAlgorithm.replace);

      for (final entry in weights.entries) {
        batch.insert(
          Tables.careerWeights,
          {
            'career_id': item['id'],
            'dimension': entry.key,
            'weight': (entry.value as num).toDouble(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final questionId in questionIds) {
        batch.insert(
          Tables.careerQuestions,
          {
            'career_id': item['id'],
            'question_id': questionId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }
}
