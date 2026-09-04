import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _dbProvider.database;
    await db.insert(
      Tables.profile, // ← correcto
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getProfile() async {
    final db = await _dbProvider.database;
    final results = await db.query(
      Tables.profile, // ← correcto
      limit: 1,
    );
    if (results.isNotEmpty) {
      return UserProfile.fromMap(results.first);
    }
    return null;
  }
}
