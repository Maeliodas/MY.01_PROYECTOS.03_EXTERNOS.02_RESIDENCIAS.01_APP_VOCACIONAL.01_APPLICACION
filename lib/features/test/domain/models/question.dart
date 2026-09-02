import '../../../../core/constants/riasec_constants.dart';

class Question {
  final String id, text;
  final RiasecType dimension;
  const Question({
    required this.id,
    required this.text,
    required this.dimension,
  });
}
