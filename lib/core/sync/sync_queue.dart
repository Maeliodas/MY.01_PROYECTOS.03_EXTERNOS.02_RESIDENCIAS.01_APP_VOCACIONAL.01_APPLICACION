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

  factory SyncItem.fromMap(Map<String, dynamic> map) {
    return SyncItem(
      id: map['id'],
      sessionId: map['session_id'],
      payload: jsonDecode(map['payload_json']),
      attempts: map['attempts'],
    );
  }
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
      DbTables.syncQueue,
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
      DbTables.syncQueue,
      where: 'status = ?',
      whereArgs: ['pending'],
      limit: 10,
    );
    return maps.map((m) => SyncItem.fromMap(m)).toList();
  }

  Future<void> remove(String id) async {
    final db = await _dbProvider.database;
    await db.delete(
      DbTables.syncQueue,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementAttempts(String id, int currentAttempts) async {
    final db = await _dbProvider.database;
    await db.update(
      DbTables.syncQueue,
      {'attempts': currentAttempts + 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
