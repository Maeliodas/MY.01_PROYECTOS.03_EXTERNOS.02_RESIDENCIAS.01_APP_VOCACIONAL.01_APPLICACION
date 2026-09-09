import '../../../../core/constants/riasec_constants.dart';

class Question {
  final int id;
  final String text;
  final RiasecDimension dimension;

  const Question({
    required this.id,
    required this.text,
    required this.dimension,
  });
}
