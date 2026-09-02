import '../../../../core/constants/careers_data.dart';
import '../../../../core/constants/riasec_constants.dart';
import '../../../test/data/questions_data.dart';
import '../models/career_match.dart';
import '../models/riasec_result.dart';

class ResultCalculator {
  RiasecResult calculate(Map<String, int> answers) {
    final s = {for (final t in RiasecType.values) t: 0};
    for (final q in questionsData) {
      final v = answers[q.id];
      if (v != null) s[q.dimension] = s[q.dimension]! + v;
    }
    return RiasecResult(s);
  }

  List<CareerMatch> rank(RiasecResult r) {
    final list = careersData.map((c) {
      var n = 0.0, d = 0.0;
      for (final t in RiasecType.values) {
        final w = c.weights[t] ?? 0;
        n += r.percentage(t) * w;
        d += w;
      }
      return CareerMatch(
        careerId: c.id,
        careerName: c.name,
        score: d == 0 ? 0 : n / d,
      );
    }).toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }
}
