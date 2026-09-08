import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/catalog_database.dart';
import '../../domain/models/catalog_models.dart';

final schoolsProvider = FutureProvider<List<School>>((ref) async {
  final db = await CatalogDatabase.instance.database;

  final rows = await db.query(
    'schools',
    orderBy: 'name',
  );

  return rows.map(School.fromMap).toList();
});

final motherLanguagesProvider = FutureProvider<List<Language>>((ref) async {
  final db = await CatalogDatabase.instance.database;

  final rows = await db.query(
    'languages',
    where: 'type = ? AND active = ?',
    whereArgs: ['mother', 1],
    orderBy: 'name',
  );

  return rows.map(Language.fromMap).toList();
});

final foreignLanguagesProvider = FutureProvider<List<Language>>((ref) async {
  final db = await CatalogDatabase.instance.database;

  final rows = await db.query(
    'languages',
    where: 'type = ? AND active = ?',
    whereArgs: ['foreign', 1],
    orderBy: 'name',
  );

  return rows.map(Language.fromMap).toList();
});
