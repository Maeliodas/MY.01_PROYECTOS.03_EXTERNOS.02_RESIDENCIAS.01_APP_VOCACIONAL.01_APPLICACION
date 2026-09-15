import '../../../../core/constants/riasec_constants.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../test/domain/models/question.dart';
import '../models/career_match.dart';
import '../models/riasec_result.dart';

class ResultCalculator {
  /// Orden estándar del modelo hexagonal RIASEC.
  ///
  /// R → I → A → S → E → C → R
  static const List<String> _riasecOrder = ['R', 'I', 'A', 'S', 'E', 'C'];

  /// Escala estándar persistida por dimensión. Aunque el número de preguntas
  /// cambie, cada dimensión se normaliza a 0–50 para conservar compatibilidad
  /// con resultados históricos y vistas existentes.
  static const double _maxDimensionScore = 50.0;

  /// Calcula las seis dimensiones RIASEC y el código Holland.
  static RiasecResult calculate(
    Map<int, double> answers,
    List<Question> questions,
  ) {
    final sums = <String, double>{'R': 0, 'I': 0, 'A': 0, 'S': 0, 'E': 0, 'C': 0};
    final counts = <String, int>{'R': 0, 'I': 0, 'A': 0, 'S': 0, 'E': 0, 'C': 0};

    String codeFor(RiasecDimension dimension) {
      switch (dimension) {
        case RiasecDimension.realistic: return 'R';
        case RiasecDimension.investigative: return 'I';
        case RiasecDimension.artistic: return 'A';
        case RiasecDimension.social: return 'S';
        case RiasecDimension.enterprising: return 'E';
        case RiasecDimension.conventional: return 'C';
      }
    }

    // Solo se consideran respuestas cuyo ID pertenece al cuestionario activo.
    // Así una pregunta desactivada no altera evaluaciones nuevas.
    final byId = {for (final question in questions) question.id: question};
    for (final entry in answers.entries) {
      final question = byId[entry.key];
      if (question == null) continue;
      final code = codeFor(question.dimension);
      sums[code] = (sums[code] ?? 0) + entry.value.clamp(0, 10).toDouble();
      counts[code] = (counts[code] ?? 0) + 1;
    }

    // Normalización dinámica. Si una dimensión tiene 8 preguntas y otra 5,
    // ninguna obtiene ventaja por tener más reactivos. El promedio 0–10 se
    // transforma a la escala histórica 0–50.
    double standardized(String code) {
      final count = counts[code] ?? 0;
      if (count == 0) return 0;
      final average = (sums[code] ?? 0) / count;
      return (average * 5).clamp(0.0, 50.0).toDouble();
    }

    final r = standardized('R');
    final i = standardized('I');
    final a = standardized('A');
    final social = standardized('S');
    final e = standardized('E');
    final c = standardized('C');

    final scores = <String, double>{
      'R': r, 'I': i, 'A': a, 'S': social, 'E': e, 'C': c,
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
      scoreS: social,
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
  /// 1. Intensidad de las seis dimensiones RIASEC del estudiante.
  /// 2. Perfil RIASEC objetivo específico de cada carrera.
  /// 3. Congruencia según el hexágono Holland.
  /// Las asociaciones pregunta-carrera son metadatos administrativos y NO
  /// otorgan puntos directos a una carrera.
  static List<CareerMatch> calculateCareerMatches(
    RiasecResult result,
    List<CareerCatalog> careers, {
    Map<int, double>? answers,
  }) {
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

    for (final career in careers) {
      final careerId = career.id;
      final careerName = career.name;
      final careerCode = career.hollandCode
          .toUpperCase()
          .split('')
          .where(_riasecOrder.contains)
          .toList();

      if (careerId.isEmpty || careerName.isEmpty || careerCode.isEmpty) {
        continue;
      }

      final affinity = _calculateAffinity(
        userScores: userScores,
        userCode: userCode,
        careerCode: careerCode,
        careerWeights: career.weights,
        questionIds: career.questionIds,
        answers: answers,
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

  /// Convierte 0–50 a 0–100.
  static double _normalize(double score) {
    return ((score.clamp(0.0, _maxDimensionScore) / _maxDimensionScore) * 100)
        .clamp(0.0, 100.0).toDouble();
  }

  /// Calcula la afinidad final de una carrera.
  ///
  /// Para evaluaciones nuevas se combinan perfil RIASEC (58 %),
  /// congruencia Holland (22 %) y preguntas específicas (20 %).
  /// Los resultados antiguos que no conservan respuestas específicas usan
  /// únicamente perfil RIASEC y congruencia Holland.
  static double _calculateAffinity({
    required Map<String, double> userScores,
    required List<String> userCode,
    required List<String> careerCode,
    required Map<String, double> careerWeights,
    required List<int> questionIds,
    Map<int, double>? answers,
  }) {
    final profileScore = careerWeights.isEmpty
        ? _calculateProfileScore(
            userScores: userScores,
            careerCode: careerCode,
          )
        : _calculateVectorProfileScore(
            userScores: userScores,
            careerWeights: careerWeights,
          );

    final hollandCongruence = _calculateHollandCongruence(
      userCode: userCode,
      careerCode: careerCode,
    );

    // Las preguntas relacionadas con una carrera sirven para trazabilidad y
    // administración del instrumento; nunca suman puntos directos a esa carrera.
    final affinity = (profileScore * 0.72) + (hollandCongruence * 0.28);
    return affinity.clamp(0.0, 100.0).toDouble();
  }

  static double _calculateVectorProfileScore({
    required Map<String, double> userScores,
    required Map<String, double> careerWeights,
  }) {
    double weightedStrength = 0;
    double weightTotal = 0;

    for (final dimension in _riasecOrder) {
      final weight = (careerWeights[dimension] ?? 0).clamp(0.0, 10.0).toDouble();
      weightedStrength += (userScores[dimension] ?? 0) * weight;
      weightTotal += weight;
    }

    if (weightTotal == 0) return 0;
    return (weightedStrength / weightTotal).clamp(0.0, 100.0).toDouble();
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

    return ((total / weightTotal) * 100).clamp(0.0, 100.0).toDouble();
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
