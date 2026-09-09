import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/models/catalog_models.dart';

/// Acceso a catálogos institucionales almacenados localmente en SQLite.
///
/// Estados, municipios, escuelas y lenguas se distribuyen con la aplicación
/// mediante el seed JSON. No se consultan APIs externas.
class CatalogRepository {
  Future<List<StateCatalog>> getStates() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(Tables.states, orderBy: 'name COLLATE NOCASE');
    return rows.map(StateCatalog.fromMap).toList();
  }

  Future<List<Municipality>> getMunicipalities(String stateId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      Tables.municipalities,
      where: 'state_id = ?',
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
          weights: {
            for (final w in weightRows)
              w['dimension']?.toString() ?? '':
                  (w['weight'] as num?)?.toDouble() ?? 0,
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
}
