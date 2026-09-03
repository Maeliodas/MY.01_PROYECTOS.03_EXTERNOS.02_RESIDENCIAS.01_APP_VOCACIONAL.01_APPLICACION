import '../../../../core/constants/careers_data.dart';
import '../../../../core/constants/riasec_constants.dart';
import '../../../test/data/questions_data.dart';
import '../models/career_match.dart';
import '../models/riasec_result.dart';

class ResultCalculator {
  static RiasecResult calculate(Map<int, int> answers) {
    double r = 0, i = 0, a = 0, s = 0, e = 0, c = 0;

    answers.forEach((qId, val) {
      final question = QuestionsData.questions.firstWhere((q) => q.id == qId);
      switch (question.dimension) {
        case RiasecDimension.realistic:
          r += val;
          break;
        case RiasecDimension.investigative:
          i += val;
          break;
        case RiasecDimension.artistic:
          a += val;
          break;
        case RiasecDimension.social:
          s += val;
          break;
        case RiasecDimension.enterprising:
          e += val;
          break;
        case RiasecDimension.conventional:
          c += val;
          break;
      }
    });

    final scores = {
      'R': r,
      'I': i,
      'A': a,
      'S': s,
      'E': e,
      'C': c,
    };

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hollandCode = '${sorted[0].key}${sorted[1].key}${sorted[2].key}';

    return RiasecResult(
      scoreR: r,
      scoreI: i,
      scoreA: a,
      scoreS: s,
      scoreE: e,
      scoreC: c,
      hollandCode: hollandCode,
    );
  }

  static List<CareerMatch> calculateCareerMatches(RiasecResult result) {
    final matches = <CareerMatch>[];

    for (final career in CareersData.ittuxCareers) {
      double score = 0;
      career.riasecWeights.forEach((dim, weight) {
        switch (dim) {
          case 'R':
            score += result.scoreR * weight;
            break;
          case 'I':
            score += result.scoreI * weight;
            break;
          case 'A':
            score += result.scoreA * weight;
            break;
          case 'S':
            score += result.scoreS * weight;
            break;
          case 'E':
            score += result.scoreE * weight;
            break;
          case 'C':
            score += result.scoreC * weight;
            break;
        }
      });

      // Normalizar porcentaje sobre 45 máximo teórico por dimensión
      final affinity = ((score / 45.0) * 100).clamp(0.0, 100.0);

      matches.add(CareerMatch(
        careerId: career.id,
        name: career.name,
        affinityPercentage: affinity,
        demandTag: career.demandTag,
      ));
    }

    matches
        .sort((a, b) => b.affinityPercentage.compareTo(a.affinityPercentage));
    return matches;
  }
}
