import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/result/data/result_local_datasource.dart';
import '../../features/result/domain/models/career_match.dart';
import '../../features/result/domain/models/riasec_result.dart';
import '../network/dashboard_api.dart';
import '../network/network_info.dart';
import 'sync_queue.dart';

class SyncService {
  SyncService({DashboardApi? api}) : _api = api ?? DashboardApi();

  final DashboardApi _api;
  final SyncQueue _queue = SyncQueue();
  final ResultLocalDatasource _results = ResultLocalDatasource();

  Future<bool> processStudentResult({
    required String resultId,
    required String sessionId,
    required UserProfile profile,
    required RiasecResult riasec,
    required CareerMatch topCareer,
  }) async {
    final payload = <String, dynamic>{
      'result_id': resultId,
      'session_id': sessionId,
      'student': {
        'local_profile_id': profile.id,
        'name': profile.name,
        'age': profile.age,
        'gender': profile.gender,
        'state_id': profile.stateId,
        'state': profile.state,
        'municipality_id': profile.municipalityId,
        'municipality': profile.municipality,
        'school_id': profile.schoolId,
        'school': profile.school,
        'language_ids': profile.languageIds,
        'languages': profile.languagesList,
      },
      'result': {
        'holland_code': riasec.hollandCode,
        'score_r': riasec.scoreR,
        'score_i': riasec.scoreI,
        'score_a': riasec.scoreA,
        'score_s': riasec.scoreS,
        'score_e': riasec.scoreE,
        'score_c': riasec.scoreC,
        'top_career_id': topCareer.careerId,
        'top_career_name': topCareer.name,
        'top_career_affinity': topCareer.affinityPercentage,
      },
      'completed_at': DateTime.now().toIso8601String(),
    };

    if (await NetworkInfo.hasConnection()) {
      final success = await _api.sendEvaluation(payload);
      if (success) {
        await _results.markSynced(resultId);
        return true;
      }
    }

    await _queue.addToQueue(
      id: resultId,
      sessionId: sessionId,
      payload: payload,
    );
    return false;
  }

  Future<void> syncPendingQueue() async {
    if (!await NetworkInfo.hasConnection()) return;

    final pending = await _queue.getPendingItems();
    for (final item in pending) {
      final success = await _api.sendEvaluation(item.payload);
      if (success) {
        await _queue.remove(item.id);
        await _results.markSynced(item.id);
      } else {
        await _queue.incrementAttempts(item.id, item.attempts);
      }
    }
  }
}
