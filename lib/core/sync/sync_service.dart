import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/result/data/result_local_datasource.dart';
import '../../features/result/domain/models/career_match.dart';
import '../../features/result/domain/models/riasec_result.dart';
import '../../features/test/data/test_local_datasource.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../network/dashboard_api.dart';
import '../network/network_info.dart';
import 'sync_queue.dart';

class SyncService {
  SyncService({DashboardApi? api}) : _api = api ?? DashboardApi();

  final DashboardApi _api;
  final SyncQueue _queue = SyncQueue();
  final ResultLocalDatasource _results = ResultLocalDatasource();
  final TestLocalDatasource _tests = TestLocalDatasource();

  Future<bool> processStudentResult({
    required String resultId,
    required String sessionId,
    required UserProfile profile,
    required RiasecResult riasec,
    required CareerMatch topCareer,
  }) async {
    final lenguas = <String>[];
    final idiomas = <String>[];
    // El tipo se lee de la tabla relacional (fuente de verdad). El orden por
    // id coincide con el orden de guardado del perfil.
    List<String> storedKinds = const [];
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        Tables.profileLanguages,
        columns: ['type'],
        where: 'profile_id = ?',
        whereArgs: [profile.id],
        orderBy: 'id ASC',
      );
      storedKinds = rows.map((r) => r['type']?.toString() ?? '').toList();
    } catch (_) {
      storedKinds = const [];
    }
    for (var index = 0; index < profile.languagesList.length; index++) {
      final name = profile.languagesList[index];
      final stored = index < storedKinds.length ? storedKinds[index] : '';
      final kind = stored == 'idioma' || stored == 'lengua'
          ? stored
          : _fallbackKind(index < profile.languageIds.length ? profile.languageIds[index] : '');
      if (kind == 'idioma') {
        idiomas.add(name);
      } else {
        lenguas.add(name);
      }
    }

    final openAnswers = await _tests.getCareerOpenAnswers(sessionId);
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
        if (profile.schoolId == null && profile.pendingSchoolName != null)
          'pending_school': {
            'name': profile.pendingSchoolName,
            'municipality_id': profile.municipalityId,
          },
        'language_ids': profile.languageIds,
        'languages': lenguas,
        'idioms': idiomas,
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
      'career_open_answers': openAnswers,
      'completed_at': DateTime.now().toIso8601String(),
    };

    if (await NetworkInfo.hasBackendConnection()) {
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

  /// Solo por compatibilidad con ids antiguos o personalizados sin fila
  /// relacional. Los ids del panel (`lan_...`) no distinguen por prefijo.
  String _fallbackKind(String id) => id.startsWith('idioma_') ? 'idioma' : 'lengua';

  static const int maxQueueAttempts = 5;

  Future<void> syncPendingQueue() async {
    if (!await NetworkInfo.hasBackendConnection()) return;

    final pending = await _queue.getPendingItems();
    for (final item in pending) {
      if (item.attempts >= maxQueueAttempts) {
        await _queue.markFailed(item.id);
        continue;
      }
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
