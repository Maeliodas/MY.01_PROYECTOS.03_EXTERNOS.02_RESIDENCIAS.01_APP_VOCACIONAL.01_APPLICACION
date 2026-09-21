import 'package:sqflite/sqflite.dart';

import '../../features/catalog/data/catalog_repository.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../network/dashboard_api.dart';
import '../network/network_info.dart';

class CatalogSyncService {
  CatalogSyncService({DashboardApi? api, CatalogRepository? repository})
      : _api = api ?? DashboardApi(),
        _repository = repository ?? CatalogRepository();

  final DashboardApi _api;
  final CatalogRepository _repository;

  /// Descarga el catálogo maestro del servidor institucional y lo guarda
  /// localmente. Si no hay conexión, se conserva el catálogo SQLite actual.
  Future<bool> sync() async {
    if (!await NetworkInfo.hasConnection()) return false;
    await _flushSuggestionQueue();
    final snapshot = await _api.fetchCatalogSnapshot();
    if (snapshot == null) return false;
    await _repository.applyServerSnapshot(snapshot);
    return true;
  }

  /// Envía una propuesta de lengua/idioma. Si el servidor no está disponible,
  /// queda en una cola relacional local (sin JSON) para enviarse después.
  Future<bool> suggest({required String kind, required String name}) async {
    final raw = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final lower = raw.toLowerCase();
    final clean = lower.isEmpty ? '' : lower[0].toUpperCase() + lower.substring(1);
    if (clean.isEmpty) return false;
    if (await NetworkInfo.hasConnection()) {
      final sent = await _api.sendCatalogSuggestion(kind: kind, name: clean);
      if (sent) return true;
    }
    final db = await AppDatabase.instance.database;
    await db.insert(
      Tables.catalogSuggestionQueue,
      {'kind': kind, 'name': clean, 'created_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return false;
  }


  /// Registra una escuela no encontrada asociada a su municipio. La fila local
  /// se conserva porque user_profile puede referenciarla mientras está pendiente.
  Future<int?> suggestSchool({required String name, required String municipalityId}) async {
    final raw = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final lower = raw.toLowerCase();
    final clean = lower.isEmpty ? '' : lower[0].toUpperCase() + lower.substring(1);
    if (clean.length < 2) return null;
    final db = await AppDatabase.instance.database;
    await db.insert(
      Tables.catalogSuggestionQueue,
      {
        'kind': 'escuela',
        'name': clean,
        'municipality_id': municipalityId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    final rows = await db.query(
      Tables.catalogSuggestionQueue,
      columns: ['id'],
      where: 'kind = ? AND name = ? AND municipality_id = ?',
      whereArgs: ['escuela', clean, municipalityId],
      limit: 1,
    );
    if (await NetworkInfo.hasConnection()) {
      await _api.sendCatalogSuggestion(kind: 'escuela', name: clean, municipalityId: municipalityId);
    }
    return rows.isEmpty ? null : (rows.first['id'] as num).toInt();
  }

  Future<void> _flushSuggestionQueue() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(Tables.catalogSuggestionQueue, orderBy: 'id ASC');
    for (final row in rows) {
      final id = row['id'];
      final kind = row['kind']?.toString() ?? '';
      final name = row['name']?.toString() ?? '';
      if (kind.isEmpty || name.isEmpty) continue;
      final municipalityId = row['municipality_id']?.toString();
      final sent = await _api.sendCatalogSuggestion(kind: kind, name: name, municipalityId: municipalityId);
      if (sent && kind != 'escuela') await db.delete(Tables.catalogSuggestionQueue, where: 'id = ?', whereArgs: [id]);
    }
  }
}
