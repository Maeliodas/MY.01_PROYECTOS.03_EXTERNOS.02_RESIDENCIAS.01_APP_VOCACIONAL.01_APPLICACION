import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _dbProvider.database;
    // Resuelve el tipo real desde el catálogo para no depender del prefijo
    // del id (los ids generados por el panel usan prefijo `lan_` tanto para
    // lenguas como para idiomas).
    final catalogIds = <String>{};
    for (var index = 0; index < profile.languagesList.length; index++) {
      final rawId = index < profile.languageIds.length ? profile.languageIds[index] : '';
      if (!rawId.contains('_custom_') && rawId.isNotEmpty) catalogIds.add(rawId);
    }
    final kindById = <String, String>{};
    if (catalogIds.isNotEmpty) {
      try {
        final rows = await db.query(
          Tables.languages,
          columns: ['id', 'type'],
          where: 'id IN (${List.filled(catalogIds.length, '?').join(',')})',
          whereArgs: catalogIds.toList(),
        );
        for (final row in rows) {
          final id = row['id']?.toString() ?? '';
          final type = row['type']?.toString() ?? '';
          if (id.isNotEmpty && (type == 'idioma' || type == 'lengua')) {
            kindById[id] = type;
          }
        }
      } catch (_) {
        // Tablas antiguas sin columna `type`: se usa el prefijo como respaldo.
      }
    }
    await db.transaction((txn) async {
      await txn.insert(Tables.profile, profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete(Tables.profileLanguages, where: 'profile_id = ?', whereArgs: [profile.id]);
      for (var index = 0; index < profile.languagesList.length; index++) {
        final rawId = index < profile.languageIds.length ? profile.languageIds[index] : '';
        final name = profile.languagesList[index];
        final isCustom = rawId.contains('_custom_') || rawId.isEmpty;
        final kind = isCustom
            ? (rawId.startsWith('idioma_') ? 'idioma' : 'lengua')
            : (kindById[rawId] ?? (rawId.startsWith('idioma_') ? 'idioma' : 'lengua'));
        await txn.insert(Tables.profileLanguages, {
          'profile_id': profile.id,
          'language_id': isCustom ? null : rawId,
          'type': kind,
          'custom_name': isCustom ? name : null,
        });
      }
    });
  }

  Future<UserProfile?> getProfile() async {
    final db = await _dbProvider.database;
    final results = await db.rawQuery('''
      SELECT p.*,
             sc.name AS school,
             m.id AS municipality_id, m.name AS municipality,
             st.id AS state_id, st.name AS state,
             q.name AS pending_school_name, q.municipality_id AS pending_municipality_id,
             pm.name AS pending_municipality, ps.id AS pending_state_id, ps.name AS pending_state
      FROM ${Tables.profile} p
      LEFT JOIN ${Tables.schools} sc ON sc.id = p.school_id
      LEFT JOIN ${Tables.municipalities} m ON m.id = sc.municipality_id
      LEFT JOIN ${Tables.states} st ON st.id = m.state_id
      LEFT JOIN ${Tables.catalogSuggestionQueue} q ON q.id = p.pending_school_suggestion_id AND q.kind = 'escuela'
      LEFT JOIN ${Tables.municipalities} pm ON pm.id = q.municipality_id
      LEFT JOIN ${Tables.states} ps ON ps.id = pm.state_id
      LIMIT 1
    ''');
    if (results.isNotEmpty && results.first['school_id'] == null) {
      final row = Map<String, dynamic>.from(results.first);
      row['municipality_id'] = row['pending_municipality_id'];
      row['municipality'] = row['pending_municipality'];
      row['state_id'] = row['pending_state_id'];
      row['state'] = row['pending_state'];
      results[0] = row;
    }
    if (results.isEmpty) return null;
    final id = results.first['id']?.toString() ?? '1';
    final languageRows = await db.query(
      Tables.profileLanguages,
      columns: ['language_id','type','custom_name'],
      where: 'profile_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );
    final ids = <String>[];
    for (var i = 0; i < languageRows.length; i++) {
      final row = languageRows[i];
      final catalogId = row['language_id']?.toString();
      if (catalogId != null && catalogId.isNotEmpty) {
        ids.add(catalogId);
      } else {
        final kind = row['type']?.toString() == 'idioma' ? 'idioma' : 'lengua';
        ids.add('${kind}_custom_saved_$i');
      }
    }
    return UserProfile.fromMap(results.first, languageIds: ids);
  }
}
