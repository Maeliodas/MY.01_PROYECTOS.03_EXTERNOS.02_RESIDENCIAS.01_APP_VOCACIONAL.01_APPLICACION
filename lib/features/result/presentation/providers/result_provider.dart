import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/result_local_datasource.dart';
import '../../domain/models/career_match.dart';
import '../../domain/models/riasec_result.dart';

class ResultData {
  final RiasecResult riasec;
  final CareerMatch topCareer;
  final List<CareerMatch> ranking;

  ResultData({
    required this.riasec,
    required this.topCareer,
    required this.ranking,
  });
}

final latestResultProvider = FutureProvider<ResultData?>((ref) async {
  final resultDs = ref.watch(resultDatasourceProvider);
  final map = await resultDs.getLatestResult();

  if (map == null) return null;

  final riasec = RiasecResult(
    scoreR: (map['score_r'] as num).toDouble(),
    scoreI: (map['score_i'] as num).toDouble(),
    scoreA: (map['score_a'] as num).toDouble(),
    scoreS: (map['score_s'] as num).toDouble(),
    scoreE: (map['score_e'] as num).toDouble(),
    scoreC: (map['score_c'] as num).toDouble(),
    hollandCode: map['holland_code'],
  );

  final topCareer = CareerMatch(
    careerId: map['top_career_id'],
    name: map['top_career_name'],
    affinityPercentage: (map['top_career_affinity'] as num).toDouble(),
    demandTag: 'Recomendación Principal',
  );

  return ResultData(
    riasec: riasec,
    topCareer: topCareer,
    ranking: [topCareer],
  );
});
