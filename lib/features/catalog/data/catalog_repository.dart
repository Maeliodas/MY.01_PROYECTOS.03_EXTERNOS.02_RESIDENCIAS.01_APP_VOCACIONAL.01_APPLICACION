import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/models/catalog_models.dart';

/// Acceso a catálogos institucionales almacenados localmente en SQLite.
///
/// Estados, municipios, escuelas y lenguas se distribuyen con la aplicación
/// mediante una base SQLite incluida con la app. No se usan JSON ni APIs externas.
class CatalogRepository {
  /// Llave donde se guarda la versión del catálogo del servidor ya aplicada.
  static const serverVersionKey = 'server_catalog_version';

  Future<List<StateCatalog>> getStates() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(Tables.states, where: 'active = 1', orderBy: 'name COLLATE NOCASE');
    return rows.map(StateCatalog.fromMap).toList();
  }

  Future<List<Municipality>> getMunicipalities(String stateId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      Tables.municipalities,
      where: 'state_id = ? AND active = 1',
      whereArgs: [stateId],
      orderBy: "CASE WHEN name = 'Otro municipio' THEN 1 ELSE 0 END, name COLLATE NOCASE",
    );
    return rows.map(Municipality.fromMap).toList();
  }

  Future<List<School>> getSchools({String? municipalityId}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      Tables.schools,
      where: municipalityId == null
          ? 'active = 1'
          : '(municipality_id = ? OR municipality_id IS NULL) AND active = 1',
      whereArgs: municipalityId == null ? null : [municipalityId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(School.fromMap).toList();
  }

  Future<List<Language>> getLanguages({String? type}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      Tables.languages,
      where: type == null ? 'active = 1' : 'type = ? AND active = 1',
      whereArgs: type == null ? null : [type],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Language.fromMap).toList();
  }

  Future<List<CareerCatalog>> getCareers() async {
    final db = await AppDatabase.instance.database;
    final careerRows = await db.query(
      Tables.careers,
      where: 'active = 1',
      orderBy: 'name COLLATE NOCASE',
    );
    final result = <CareerCatalog>[];
    for (final row in careerRows) {
      final id = row['id']?.toString() ?? '';
      final weightRows = await db.query(
        Tables.careerWeights,
        where: 'career_id = ?',
        whereArgs: [id],
      );
      final questionRows = await db.query(
        Tables.careerQuestions,
        columns: ['question_id'],
        where: 'career_id = ?',
        whereArgs: [id],
      );
      result.add(
        CareerCatalog(
          id: id,
          name: row['name']?.toString() ?? '',
          description: row['description']?.toString() ?? '',
          hollandCode: row['holland_code']?.toString() ?? '',
          department: row['department']?.toString() ?? '',
          websiteUrl: row['website_url']?.toString() ?? '',
          weights: {
            for (final w in weightRows)
              w['dimension']?.toString() ?? '':
                  double.tryParse(w['weight']?.toString() ?? '') ?? 0,
          }..remove(''),
          questionIds: questionRows
              .map((q) => (q['question_id'] as num?)?.toInt())
              .whereType<int>()
              .toList(),
        ),
      );
    }
    return result;
  }

  Future<List<DepartmentQuestion>> getDepartmentQuestions() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      Tables.departmentQuestions,
      orderBy: 'department COLLATE NOCASE',
    );
    return rows.map(DepartmentQuestion.fromMap).toList();
  }

  Future<void> applyServerSnapshot(Map<String, dynamic> snapshot) async {
    final db = await AppDatabase.instance.database;
    // Si la versión no cambió, no hay nada que aplicar: se evita reescribir
    // cientos de filas (y una transacción larga) en cada arranque.
    final incomingVersion = snapshot['version']?.toString() ?? '';
    if (incomingVersion.isNotEmpty) {
      final local = await db.query(
        Tables.metadata,
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['server_catalog_version'],
        limit: 1,
      );
      if (local.isNotEmpty &&
          local.first['value']?.toString() == incomingVersion) {
        return;
      }
    }
    await db.transaction((txn) async {
      Future<void> upsertList(
        String table,
        dynamic raw,
        List<String> keyColumns,
      ) async {
        if (raw is! List) return;
        for (final item in raw) {
          if (item is! Map) continue;
          final values = Map<String, Object?>.from(item);
          for (final key in keyColumns) {
            if (values[key] == null) {
              throw StateError(
                'Catálogo $table con clave nula (${keyColumns.join(',')})',
              );
            }
          }
          final cols = values.keys.toList();
          final args = cols.map((c) => values[c]).toList();
          final placeholders = List.filled(cols.length, '?').join(',');
          // UPSERT en una sola sentencia (sin REPLACE para no disparar
          // cascadas de FK sobre resultados históricos).
          final updatable =
              cols.where((c) => !keyColumns.contains(c)).toList();
          final sql = updatable.isEmpty
              ? 'INSERT OR IGNORE INTO $table (${cols.join(',')}) VALUES ($placeholders)'
              : 'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders) '
                  'ON CONFLICT(${keyColumns.join(',')}) DO UPDATE SET '
                  '${updatable.map((c) => '$c=excluded.$c').join(',')}';
          try {
            await txn.rawInsert(sql, args);
          } catch (e) {
            throw StateError(
              'Catálogo $table '
              '(${keyColumns.map((k) => values[k]).join('/')}): $e',
            );
          }
        }
      }

      await upsertList(Tables.states, snapshot['states'], const ['id']);
      await upsertList(Tables.municipalities, snapshot['municipalities'], const ['id']);
      await upsertList(Tables.schools, snapshot['schools'], const ['id']);
      await upsertList(Tables.languages, snapshot['languages'], const ['id']);
      await upsertList(Tables.questions, snapshot['questions'], const ['id']);
      await upsertList(Tables.careers, snapshot['careers'], const ['id']);
      await upsertList(Tables.departmentQuestions, snapshot['department_questions'], const ['department']);
      await upsertList(
        Tables.careerWeights,
        snapshot['career_weights'],
        const ['career_id', 'dimension'],
      );
      await upsertList(
        Tables.careerQuestions,
        snapshot['career_questions'],
        const ['career_id', 'question_id'],
      );

      final version = snapshot['version']?.toString();
      if (version != null && version.isNotEmpty) {
        await txn.insert(
          Tables.metadata,
          {'key': CatalogRepository.serverVersionKey, 'value': version},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

}
