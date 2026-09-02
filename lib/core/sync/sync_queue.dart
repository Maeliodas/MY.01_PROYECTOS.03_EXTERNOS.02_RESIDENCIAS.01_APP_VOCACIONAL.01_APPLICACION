import 'dart:convert';
import '../database/app_database.dart';
import '../database/tables.dart';

class SyncQueue {
  final AppDatabase db;
  SyncQueue({AppDatabase? database}) : db = database ?? AppDatabase.instance;
  Future<void> add(String type, String id, Map<String, dynamic> payload) async {
    final d = await db.database;
    await d.insert(Tables.syncQueue, {
      'entityType': type,
      'entityId': id,
      'payloadJson': jsonEncode(payload),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
