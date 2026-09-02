import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/riasec_constants.dart';
import '../../data/result_local_datasource.dart';
import '../../domain/models/career_match.dart';
import '../../domain/models/riasec_result.dart';
import '../../domain/services/result_calculator.dart';

final resultDataSourceProvider = Provider((ref) => ResultLocalDataSource());
final resultCalculatorProvider = Provider((ref) => ResultCalculator());
final latestResultProvider = FutureProvider(
  (ref) => ref.read(resultDataSourceProvider).latest(),
);
RiasecResult riasecFromJson(Map<String, dynamic> j) => RiasecResult({
  for (final t in RiasecType.values) t: (j[t.code] as num?)?.toInt() ?? 0,
});
List<CareerMatch> careersFromJson(List<dynamic> x) => x.map((e) {
  final m = e as Map;
  return CareerMatch(
    careerId: m['id'],
    careerName: m['name'],
    score: (m['score'] as num).toDouble(),
  );
}).toList();
