import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.insert(Tables.profile, profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete(Tables.profileLanguages, where: 'profile_id = ?', whereArgs: [profile.id]);
      for (var index = 0; index < profile.languagesList.length; index++) {
        final rawId = index < profile.languageIds.length ? profile.languageIds[index] : '';
        final name = profile.languagesList[index];
        final isCustom = rawId.contains('_custom_') || rawId.isEmpty;
        final kind = rawId.startsWith('idioma_') ? 'idioma' : 'lengua';
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
    final results = await db.query(Tables.profile, limit: 1);
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
