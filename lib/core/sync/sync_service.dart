import 'dart:convert';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../network/analytics_api.dart';
import '../network/network_info.dart';

class SyncService {
  final AppDatabase db;
  final AnalyticsApi api;
  final NetworkInfo net;
  SyncService({
    AppDatabase? database,
    AnalyticsApi? api,
    NetworkInfo? networkInfo,
  }) : db = database ?? AppDatabase.instance,
       api = api ?? AnalyticsApi(),
       net = networkInfo ?? NetworkInfo();
  Future<void> syncInBackground() async {
    try {
      if (!await net.isConnected) return;
      final d = await db.database;
      final rows = await d.query(
        Tables.syncQueue,
        orderBy: 'id ASC',
        limit: 20,
      );
      for (final row in rows) {
        try {
          await api.send(jsonDecode(row['payloadJson'] as String));
          await d.delete(
            Tables.syncQueue,
            where: 'id=?',
            whereArgs: [row['id']],
          );
        } catch (e) {
          await d.update(
            Tables.syncQueue,
            {'attempts': (row['attempts'] as int) + 1, 'lastError': '$e'},
            where: 'id=?',
            whereArgs: [row['id']],
          );
        }
      }
    } catch (_) {}
  }
}
