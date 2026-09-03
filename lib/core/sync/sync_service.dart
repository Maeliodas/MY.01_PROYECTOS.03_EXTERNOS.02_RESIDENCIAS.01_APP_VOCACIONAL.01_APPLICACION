import '../network/analytics_api.dart';
import '../network/network_info.dart';
import 'sync_queue.dart';

class SyncService {
  final AnalyticsApi _api = AnalyticsApi();
  final SyncQueue _queue = SyncQueue();

  /// Sincronización inmediata no bloqueante o encolamiento
  Future<bool> processSessionResult({
    required String id,
    required String sessionId,
    required Map<String, dynamic> anonymousPayload,
  }) async {
    final bool isConnected = await NetworkInfo.hasConnection();

    if (isConnected) {
      final bool success = await _api.sendAnonymousResult(anonymousPayload);
      if (success) {
        return true;
      }
    }

    // Si no hay red o falló el envío, encolar en SQLite
    await _queue.addToQueue(
      id: id,
      sessionId: sessionId,
      payload: anonymousPayload,
    );

    return false;
  }

  /// Intenta vaciar la cola pendiente en segundo plano
  Future<void> syncPendingQueue() async {
    if (!await NetworkInfo.hasConnection()) return;

    final pending = await _queue.getPendingItems();
    for (final item in pending) {
      final success = await _api.sendAnonymousResult(item.payload);
      if (success) {
        await _queue.remove(item.id);
      } else {
        await _queue.incrementAttempts(item.id, item.attempts);
      }
    }
  }
}
