import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.insert(
        Tables.profile,
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        Tables.profileLanguages,
        where: 'profile_id = ?',
        whereArgs: [profile.id],
      );
      for (var index = 0; index < profile.languagesList.length; index++) {
        final languageId = index < profile.languageIds.length
            ? profile.languageIds[index]
            : null;
        await txn.insert(Tables.profileLanguages, {
          'profile_id': profile.id,
          'language_id': languageId,
          'type': 'selected',
          'custom_name': languageId == null ? profile.languagesList[index] : null,
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
      columns: ['language_id'],
      where: 'profile_id = ? AND language_id IS NOT NULL',
      whereArgs: [id],
    );
    return UserProfile.fromMap(
      results.first,
      languageIds: languageRows
          .map((row) => row['language_id']?.toString())
          .whereType<String>()
          .toList(),
    );
  }
}
