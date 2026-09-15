import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

/// Carga los catálogos desde una base SQLite preconstruida.
/// No se utilizan archivos JSON ni servicios externos.
class DatabaseSeed {
  const DatabaseSeed._();

  static const _asset = 'assets/database/aevum_catalog_v13.db';

  static Future<void> apply(DatabaseExecutor db) async {
    final bytes = await rootBundle.load(_asset);
    final databaseRoot = await getDatabasesPath();
    final seedPath = join(databaseRoot, 'aevum_catalog_seed_v13.db');
    final file = File(seedPath);
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );

    final seed = await openDatabase(seedPath, readOnly: true);
    try {
      final batch = db.batch();
      await _copy(seed, batch, Tables.states);
      await _copy(seed, batch, Tables.municipalities);
      await _copy(seed, batch, Tables.schools);
      await _copy(seed, batch, Tables.languages);
      await _copy(seed, batch, Tables.questions);
      await _copy(seed, batch, Tables.careers);
      await _copy(seed, batch, Tables.departmentQuestions);
      await _copy(seed, batch, Tables.careerWeights);
      await _copy(seed, batch, Tables.careerQuestions);
      await batch.commit(noResult: true);
    } finally {
      await seed.close();
      if (await file.exists()) await file.delete();
    }
  }

  static Future<void> _copy(
    Database seed,
    Batch batch,
    String table,
  ) async {
    final rows = await seed.query(table);
    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
