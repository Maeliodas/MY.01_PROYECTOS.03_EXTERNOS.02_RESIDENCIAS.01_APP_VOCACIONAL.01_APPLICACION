import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRepository {
  final AppDatabase db;
  ProfileRepository({AppDatabase? database})
    : db = database ?? AppDatabase.instance;
  Future<UserProfile?> get() async {
    final d = await db.database;
    final r = await d.query(Tables.profile, limit: 1);
    if (r.isEmpty) return null;
    final x = r.first;
    return UserProfile(
      name: x['name'] as String,
      age: x['age'] as int?,
      gender: x['gender'] as String?,
      schoolId: x['schoolId'] as String?,
      schoolNameSnapshot: x['schoolNameSnapshot'] as String?,
      languageIds: (jsonDecode(x['languageIds'] as String? ?? '[]') as List)
          .cast<String>(),
      languageNamesSnapshot:
          (jsonDecode(x['languageNamesSnapshot'] as String? ?? '[]') as List)
              .cast<String>(),
      otherLanguage: x['otherLanguage'] as String?,
      avatarId: x['avatarId'] as String? ?? '',
    );
  }

  Future<void> save(UserProfile p) async {
    final d = await db.database;
    await d.insert(Tables.profile, {
      'id': 1,
      'name': p.name,
      'age': p.age,
      'gender': p.gender,
      'schoolId': p.schoolId,
      'schoolNameSnapshot': p.schoolNameSnapshot,
      'languageIds': jsonEncode(p.languageIds),
      'languageNamesSnapshot': jsonEncode(p.languageNamesSnapshot),
      'otherLanguage': p.otherLanguage,
      'avatarId': p.avatarId,
      'updatedAt': AppDateUtils.now(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, String>>> schools() async {
    final d = await db.database;
    final r = await d.query(Tables.schools, where: 'active=1', orderBy: 'name');
    return r
        .map((x) => {'id': x['id'] as String, 'name': x['name'] as String})
        .toList();
  }

  Future<List<Map<String, String>>> languages() async {
    final d = await db.database;
    final r = await d.query(
      Tables.languages,
      where: 'active=1',
      orderBy: 'name',
    );
    return r
        .map((x) => {'id': x['id'] as String, 'name': x['name'] as String})
        .toList();
  }
}
