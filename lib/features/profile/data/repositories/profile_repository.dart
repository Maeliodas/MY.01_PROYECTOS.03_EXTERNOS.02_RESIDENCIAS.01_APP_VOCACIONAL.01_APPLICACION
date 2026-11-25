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
    try {
      final db = await _dbProvider.database;

      // 1. Consultar el perfil básico sin JOINs (nunca falla por tablas relacionadas)
      final profileRows = await db.query(
        Tables.profile,
        limit: 1,
      );
      if (profileRows.isEmpty) return null;
      final profileRow = Map<String, dynamic>.from(profileRows.first);
      final id = profileRow['id']?.toString() ?? '1';

      // 2. Obtener escuela, municipio y estado por consultas separadas
      String? schoolName;
      String? municipalityName;
      String? stateName;
      String? municipalityId = profileRow['municipality_id']?.toString();
      String? stateId = profileRow['state_id']?.toString();

      if (municipalityId != null && municipalityId.isNotEmpty) {
        final mRows = await db.query(
          Tables.municipalities,
          columns: ['name', 'state_id'],
          where: 'id = ?',
          whereArgs: [municipalityId],
          limit: 1,
        );
        if (mRows.isNotEmpty) {
          municipalityName = mRows.first['name']?.toString();
          stateId = mRows.first['state_id']?.toString() ?? stateId;
        }
      }

      if (stateId != null && stateId.isNotEmpty) {
        final sRows = await db.query(
          Tables.states,
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [stateId],
          limit: 1,
        );
        if (sRows.isNotEmpty) {
          stateName = sRows.first['name']?.toString();
        }
      }

      final schoolId = profileRow['school_id']?.toString();
      if (schoolId != null && schoolId.isNotEmpty) {
        final sRows = await db.query(
          Tables.schools,
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [schoolId],
          limit: 1,
        );
        if (sRows.isNotEmpty) {
          schoolName = sRows.first['name']?.toString();
        }
      }

      // 3. Obtener nombre de escuela sugerida pendiente (si aplica)
      String? pendingSchoolName = profileRow['pending_school_name']?.toString();
      final pendingSuggestionId = profileRow['pending_school_suggestion_id'];
      if (pendingSchoolName == null || pendingSchoolName.isEmpty) {
        if (pendingSuggestionId != null) {
          final qRows = await db.query(
            Tables.catalogSuggestionQueue,
            columns: ['name'],
            where: 'id = ? AND kind = ?',
            whereArgs: [pendingSuggestionId, 'escuela'],
            limit: 1,
          );
          if (qRows.isNotEmpty) {
            pendingSchoolName = qRows.first['name']?.toString();
          }
        }
      }

      // 4. Si no hay municipio/estado desde el perfil, intentar desde la sugerencia pendiente
      if ((municipalityName == null || municipalityName.isEmpty) &&
          pendingSuggestionId != null) {
        final qRows = await db.query(
          Tables.catalogSuggestionQueue,
          columns: ['municipality_id', 'name'],
          where: 'id = ? AND kind = ?',
          whereArgs: [pendingSuggestionId, 'escuela'],
          limit: 1,
        );
        if (qRows.isNotEmpty) {
          final sugMunicipalityId = qRows.first['municipality_id']?.toString();
          if (sugMunicipalityId != null && sugMunicipalityId.isNotEmpty) {
            final mRows = await db.query(
              Tables.municipalities,
              columns: ['name', 'state_id'],
              where: 'id = ?',
              whereArgs: [sugMunicipalityId],
              limit: 1,
            );
            if (mRows.isNotEmpty) {
              municipalityName = mRows.first['name']?.toString() ?? municipalityName;
              final sugStateId = mRows.first['state_id']?.toString();
              if (sugStateId != null && sugStateId.isNotEmpty && stateName == null) {
                final sRows = await db.query(
                  Tables.states,
                  columns: ['name'],
                  where: 'id = ?',
                  whereArgs: [sugStateId],
                  limit: 1,
                );
                if (sRows.isNotEmpty) {
                  stateName = sRows.first['name']?.toString();
                }
              }
            }
          }
        }
      }

      // 5. Construir el mapa para UserProfile.fromMap con todos los datos resueltos
      final row = <String, dynamic>{
        'id': profileRow['id'],
        'name': profileRow['name'],
        'age': profileRow['age'],
        'gender': profileRow['gender'],
        'school_id': schoolId,
        'pending_school_suggestion_id': pendingSuggestionId,
        'speaks_languages': profileRow['speaks_languages'],
        'languages_list': profileRow['languages_list'],
        'avatar_config_json': profileRow['avatar_config_json'],
        'created_at': profileRow['created_at'],
        'state_id': stateId,
        'state': stateName ?? profileRow['state'] ?? 'No especificado',
        'municipality_id': municipalityId,
        'municipality': municipalityName ?? profileRow['municipality'] ?? 'No especificado',
        'school': schoolName ?? pendingSchoolName ?? profileRow['school'] ?? 'No especificada',
        'pending_school_name': pendingSchoolName,
      };

      // 6. Consultar idiomas del perfil
      final languageRows = await db.query(
        Tables.profileLanguages,
        columns: ['language_id', 'type', 'custom_name'],
        where: 'profile_id = ?',
        whereArgs: [id],
        orderBy: 'id ASC',
      );
      final ids = <String>[];
      for (var i = 0; i < languageRows.length; i++) {
        final langRow = languageRows[i];
        final catalogId = langRow['language_id']?.toString();
        if (catalogId != null && catalogId.isNotEmpty) {
          ids.add(catalogId);
        } else {
          final kind = langRow['type']?.toString() == 'idioma' ? 'idioma' : 'lengua';
          ids.add('${kind}_custom_saved_$i');
        }
      }

      return UserProfile.fromMap(row, languageIds: ids);
    } catch (e) {
      print('ProfileRepository: no se pudo cargar el perfil local ($e)');
      return null;
    }
  }
}
