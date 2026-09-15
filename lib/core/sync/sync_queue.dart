import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

class SyncItem {
  final String id;
  final String sessionId;
  final Map<String, dynamic> payload;
  final int attempts;

  SyncItem({
    required this.id,
    required this.sessionId,
    required this.payload,
    required this.attempts,
  });

  factory SyncItem.fromMap(Map<String, Object?> map) => SyncItem(
        id: map['id']?.toString() ?? '',
        sessionId: map['session_id']?.toString() ?? '',
        payload: Map<String, dynamic>.from(
          jsonDecode(map['payload_json']?.toString() ?? '{}') as Map,
        ),
        attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      );
}

class SyncQueue {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<void> addToQueue({
    required String id,
    required String sessionId,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _dbProvider.database;
    await db.insert(
      Tables.syncQueue,
      {
        'id': id,
        'session_id': sessionId,
        'payload_json': jsonEncode(payload),
        'attempts': 0,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncItem>> getPendingItems() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      Tables.syncQueue,
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
      limit: 20,
    );
    return maps.map(SyncItem.fromMap).toList();
  }

  Future<void> remove(String id) async {
    final db = await _dbProvider.database;
    await db.delete(Tables.syncQueue, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementAttempts(String id, int currentAttempts) async {
    final db = await _dbProvider.database;
    await db.update(
      Tables.syncQueue,
      {'attempts': currentAttempts + 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
