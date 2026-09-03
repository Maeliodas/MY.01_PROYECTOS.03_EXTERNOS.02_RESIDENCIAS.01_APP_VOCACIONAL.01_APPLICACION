import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/result_local_datasource.dart';
import '../../domain/models/career_match.dart';
import '../../domain/models/riasec_result.dart';
import '../../test/presentation/providers/test_provider.dart';

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
    scoreR: map['score_r'],
    scoreI: map['score_i'],
    scoreA: map['score_a'],
    scoreS: map['score_s'],
    scoreE: map['score_e'],
    scoreC: map['score_c'],
    hollandCode: map['holland_code'],
  );

  final topCareer = CareerMatch(
    careerId: map['top_career_id'],
    name: map['top_career_name'],
    affinityPercentage: map['top_career_affinity'],
    demandTag: 'Recomendación Principal',
  );

  return ResultData(
    riasec: riasec,
    topCareer: topCareer,
    ranking: [topCareer],
  );
});
