import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/presentation/providers/catalog_providers.dart';
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

  List<CareerMatch> get topThree => ranking.take(3).toList();
}

final resultHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(resultDatasourceProvider).getAllResults();
});

final latestResultProvider = FutureProvider<ResultData?>((ref) async {
  final map = await ref.watch(resultDatasourceProvider).getLatestResult();
  if (map == null) return null;

  final riasec = RiasecResult(
    scoreR: _readDouble(map['score_r']),
    scoreI: _readDouble(map['score_i']),
    scoreA: _readDouble(map['score_a']),
    scoreS: _readDouble(map['score_s']),
    scoreE: _readDouble(map['score_e']),
    scoreC: _readDouble(map['score_c']),
    hollandCode: map['holland_code']?.toString() ?? '',
  );

  final savedRanking = _decodeRanking(map['full_ranking_json']);
  final ranking = savedRanking.isNotEmpty
      ? savedRanking
      : ResultCalculator.calculateCareerMatches(
          riasec,
          await ref.watch(careersCatalogProvider.future),
        );

  if (ranking.isEmpty) return null;
  return ResultData(riasec: riasec, topCareer: ranking.first, ranking: ranking);
});

List<CareerMatch> _decodeRanking(dynamic raw) {
  if (raw == null) return const [];
  try {
    final decoded = jsonDecode(raw.toString());
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => CareerMatch(
              careerId: item['career_id']?.toString() ?? '',
              name: item['name']?.toString() ?? 'Carrera',
              affinityPercentage: _readDouble(item['affinity']),
              demandTag: item['demand_tag']?.toString() ?? '',
            ))
        .where((item) => item.careerId.isNotEmpty)
        .toList();
  } catch (_) {
    return const [];
  }
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
