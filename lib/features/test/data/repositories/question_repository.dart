import '../../../../core/constants/riasec_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../domain/models/question.dart';

class QuestionRepository {
  const QuestionRepository();

  Future<List<Question>> getActiveQuestions() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      Tables.questions,
      where: 'active = 1',
      orderBy: 'position ASC',
    );
    return rows.map((row) {
      return Question(
        id: (row['id'] as num).toInt(),
        text: row['text']?.toString() ?? '',
        dimension: _dimensionFromCode(row['dimension']?.toString() ?? ''),
      );
    }).toList();
  }

  RiasecDimension _dimensionFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'R':
        return RiasecDimension.realistic;
      case 'I':
        return RiasecDimension.investigative;
      case 'A':
        return RiasecDimension.artistic;
      case 'S':
        return RiasecDimension.social;
      case 'E':
        return RiasecDimension.enterprising;
      case 'C':
        return RiasecDimension.conventional;
      default:
        throw StateError('Dimensión RIASEC desconocida: $code');
    }
  }
}
