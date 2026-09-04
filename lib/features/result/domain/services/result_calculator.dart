import '../../../../core/constants/careers_data.dart';
import '../../../../core/constants/riasec_constants.dart';
import '../../../test/data/questions_data.dart';
import '../models/career_match.dart';
import '../models/riasec_result.dart';

class ResultCalculator {
  /// Orden estándar del modelo hexagonal RIASEC.
  ///
  /// R → I → A → S → E → C → R
  static const List<String> _riasecOrder = ['R', 'I', 'A', 'S', 'E', 'C'];

  /// Máximo posible por dimensión:
  ///
  /// 5 preguntas × 9 puntos = 45.
  static const double _maxDimensionScore = 45.0;

  /// Calcula las seis dimensiones RIASEC y el código Holland.
  static RiasecResult calculate(Map<int, int> answers) {
    double r = 0;
    double i = 0;
    double a = 0;
    double s = 0;
    double e = 0;
    double c = 0;

    for (final entry in answers.entries) {
      final question = QuestionsData.questions.firstWhere(
        (question) => question.id == entry.key,
      );

      final value = entry.value.clamp(0, 9).toDouble();

      switch (question.dimension) {
        case RiasecDimension.realistic:
          r += value;
          break;

        case RiasecDimension.investigative:
          i += value;
          break;

        case RiasecDimension.artistic:
          a += value;
          break;

        case RiasecDimension.social:
          s += value;
          break;

        case RiasecDimension.enterprising:
          e += value;
          break;

        case RiasecDimension.conventional:
          c += value;
          break;
      }
    }

    final scores = <String, double>{
      'R': r,
      'I': i,
      'A': a,
      'S': s,
      'E': e,
      'C': c,
    };

    final sortedScores = scores.entries.toList()
      ..sort((first, second) {
        final scoreComparison = second.value.compareTo(first.value);

        if (scoreComparison != 0) {
          return scoreComparison;
        }

        return _riasecOrder
            .indexOf(first.key)
            .compareTo(_riasecOrder.indexOf(second.key));
      });

    final hollandCode = sortedScores.take(3).map((entry) => entry.key).join();

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

  /// Genera el ranking completo de carreras.
  ///
  /// Cada carrera contiene uno o más códigos Holland.
  ///
  /// Ejemplo:
  /// I,R,C
  ///
  /// La afinidad considera:
  ///
  /// 1. Intensidad de las dimensiones RIASEC del estudiante.
  /// 2. Coincidencia de sus dimensiones dominantes.
  /// 3. Congruencia según el hexágono RIASEC.
  /// 4. Posición de las dimensiones dentro del código Holland.
  static List<CareerMatch> calculateCareerMatches(RiasecResult result) {
    final userScores = <String, double>{
      'R': _normalize(result.scoreR),
      'I': _normalize(result.scoreI),
      'A': _normalize(result.scoreA),
      'S': _normalize(result.scoreS),
      'E': _normalize(result.scoreE),
      'C': _normalize(result.scoreC),
    };

    final userCode = result.hollandCode
        .toUpperCase()
        .split('')
        .where(_riasecOrder.contains)
        .toList();

    final matches = <CareerMatch>[];

    for (final career in CareersData.initialCareers) {
      final careerId = career['id'] ?? '';
      final careerName = career['name'] ?? '';
      final hollandCodes = career['holland_codes'] ?? '';

      final careerCode = hollandCodes
          .split(',')
          .map((code) => code.trim().toUpperCase())
          .where(_riasecOrder.contains)
          .toList();

      if (careerId.isEmpty || careerName.isEmpty || careerCode.isEmpty) {
        continue;
      }

      final affinity = _calculateAffinity(
        userScores: userScores,
        userCode: userCode,
        careerCode: careerCode,
      );

      matches.add(
        CareerMatch(
          careerId: careerId,
          name: careerName,
          affinityPercentage: affinity,
          demandTag: '',
        ),
      );
    }

    matches.sort((first, second) {
      final affinityComparison = second.affinityPercentage.compareTo(
        first.affinityPercentage,
      );

      if (affinityComparison != 0) {
        return affinityComparison;
      }

      return first.name.compareTo(second.name);
    });

    return matches;
  }

  /// Convierte 0–45 a 0–100.
  static double _normalize(double score) {
    return ((score.clamp(0.0, _maxDimensionScore) / _maxDimensionScore) * 100)
        .clamp(0.0, 100.0);
  }

  /// Calcula la afinidad final de una carrera.
  ///
  /// Se combinan dos elementos:
  ///
  /// 60 %:
  /// Puntuación real del estudiante en las dimensiones
  /// que componen la carrera.
  ///
  /// 40 %:
  /// Congruencia entre el código Holland del estudiante
  /// y el código Holland de la carrera.
  static double _calculateAffinity({
    required Map<String, double> userScores,
    required List<String> userCode,
    required List<String> careerCode,
  }) {
    final profileScore = _calculateProfileScore(
      userScores: userScores,
      careerCode: careerCode,
    );

    final hollandCongruence = _calculateHollandCongruence(
      userCode: userCode,
      careerCode: careerCode,
    );

    final affinity = (profileScore * 0.60) + (hollandCongruence * 0.40);

    return affinity.clamp(0.0, 100.0);
  }

  /// Determina qué tan fuerte es el perfil del estudiante
  /// en las dimensiones que requiere la carrera.
  static double _calculateProfileScore({
    required Map<String, double> userScores,
    required List<String> careerCode,
  }) {
    double total = 0;
    double weightTotal = 0;

    for (var index = 0; index < careerCode.length; index++) {
      final dimension = careerCode[index];
      final score = userScores[dimension] ?? 0;

      /*
       * Primera dimensión del código = mayor peso.
       *
       * 1.º = 1.00
       * 2.º = 0.85
       * 3.º = 0.70
       */
      final weight = 1.0 - (index * 0.15);

      total += score * weight;
      weightTotal += weight;
    }

    if (weightTotal == 0) {
      return 0;
    }

    return total / weightTotal;
  }

  /// Calcula la congruencia entre el código Holland
  /// del estudiante y el código de la carrera.
  static double _calculateHollandCongruence({
    required List<String> userCode,
    required List<String> careerCode,
  }) {
    if (userCode.isEmpty || careerCode.isEmpty) {
      return 0;
    }

    double total = 0;
    double weightTotal = 0;

    for (var careerIndex = 0; careerIndex < careerCode.length; careerIndex++) {
      final careerDimension = careerCode[careerIndex];

      /*
       * Las primeras dimensiones de una carrera tienen
       * mayor importancia.
       */
      final careerWeight = 1.0 - (careerIndex * 0.15);

      double bestCongruence = 0;

      for (var userIndex = 0; userIndex < userCode.length; userIndex++) {
        final userDimension = userCode[userIndex];

        final distance = _hexagonDistance(careerDimension, userDimension);

        final congruence = _congruenceFromDistance(distance);

        /*
         * Las primeras dimensiones del Holland del
         * estudiante también tienen mayor peso.
         */
        final userWeight = 1.0 - (userIndex * 0.15);

        final weightedCongruence = congruence * userWeight;

        if (weightedCongruence > bestCongruence) {
          bestCongruence = weightedCongruence;
        }
      }

      total += bestCongruence * careerWeight;
      weightTotal += careerWeight;
    }

    if (weightTotal == 0) {
      return 0;
    }

    return ((total / weightTotal) * 100).clamp(0.0, 100.0);
  }

  /// Distancia entre dos dimensiones dentro del
  /// hexágono RIASEC.
  ///
  /// Ejemplo:
  ///
  /// R ↔ R = 0
  /// R ↔ I = 1
  /// R ↔ C = 1
  /// R ↔ A = 2
  /// R ↔ E = 2
  /// R ↔ S = 3
  static int _hexagonDistance(String first, String second) {
    final firstIndex = _riasecOrder.indexOf(first);

    final secondIndex = _riasecOrder.indexOf(second);

    if (firstIndex == -1 || secondIndex == -1) {
      return 3;
    }

    final directDistance = (firstIndex - secondIndex).abs();

    final circularDistance = _riasecOrder.length - directDistance;

    return directDistance < circularDistance
        ? directDistance
        : circularDistance;
  }

  /// Congruencia según distancia en el hexágono.
  ///
  /// 0 = misma dimensión
  /// 1 = adyacente
  /// 2 = dos posiciones
  /// 3 = opuesta
  static double _congruenceFromDistance(int distance) {
    switch (distance) {
      case 0:
        return 1.00;

      case 1:
        return 0.75;

      case 2:
        return 0.50;

      case 3:
        return 0.25;

      default:
        return 0.0;
    }
  }
}
