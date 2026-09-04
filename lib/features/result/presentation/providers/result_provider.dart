import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/result_local_datasource.dart';
import '../../domain/models/career_match.dart';
import '../../domain/models/riasec_result.dart';
import '../../domain/services/result_calculator.dart';

class ResultData {
  final RiasecResult riasec;
  final CareerMatch topCareer;
  final List<CareerMatch> ranking;

  const ResultData({
    required this.riasec,
    required this.topCareer,
    required this.ranking,
  });

  List<CareerMatch> get topThree {
    return ranking.take(3).toList();
  }
}

final latestResultProvider = FutureProvider<ResultData?>((ref) async {
  final resultDs = ref.watch(resultDatasourceProvider);

  final map = await resultDs.getLatestResult();

  if (map == null) {
    return null;
  }

  final riasec = RiasecResult(
    scoreR: _readDouble(map['score_r']),
    scoreI: _readDouble(map['score_i']),
    scoreA: _readDouble(map['score_a']),
    scoreS: _readDouble(map['score_s']),
    scoreE: _readDouble(map['score_e']),
    scoreC: _readDouble(map['score_c']),
    hollandCode: map['holland_code']?.toString() ?? '',
  );

  final ranking = ResultCalculator.calculateCareerMatches(riasec);

  if (ranking.isEmpty) {
    return null;
  }

  return ResultData(riasec: riasec, topCareer: ranking.first, ranking: ranking);
});

double _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
