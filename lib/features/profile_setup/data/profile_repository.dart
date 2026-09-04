import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

class ProfileRepository {
  Future<void> saveLanguages({
    required String? schoolId,
    required bool speaksMother,
    required List<String> motherIds,
    required List<String> customMother,
    required bool speaksForeign,
    required List<String> foreignIds,
    required List<String> customForeign,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.insert(Tables.profile, {
        'id': 1,
        'school_id': schoolId,
        'speaks_mother_tongue': speaksMother ? 1 : 0,
        'speaks_foreign_language': speaksForeign ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(Tables.profileLanguages);

      for (final id in motherIds) {
        await txn.insert(Tables.profileLanguages, {
          'language_id': id,
          'type': 'mother',
        });
      }

      for (final name in customMother) {
        await txn.insert(Tables.profileLanguages, {
          'type': 'mother',
          'custom_name': name,
        });
      }

      for (final id in foreignIds) {
        await txn.insert(Tables.profileLanguages, {
          'language_id': id,
          'type': 'foreign',
        });
      }

      for (final name in customForeign) {
        await txn.insert(Tables.profileLanguages, {
          'type': 'foreign',
          'custom_name': name,
        });
      }
    });
  }
}
