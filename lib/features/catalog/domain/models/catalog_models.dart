class StateCatalog {
  final String id;
  final String name;
  const StateCatalog({required this.id, required this.name});
  factory StateCatalog.fromMap(Map<String, Object?> map) => StateCatalog(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
      );
}

class Municipality {
  final String id;
  final String stateId;
  final String name;
  const Municipality({
    required this.id,
    required this.stateId,
    required this.name,
  });
  factory Municipality.fromMap(Map<String, Object?> map) => Municipality(
        id: map['id']?.toString() ?? '',
        stateId: map['state_id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
      );
}

class School {
  final String id;
  final String name;
  final String? municipalityId;
  const School({
    required this.id,
    required this.name,
    this.municipalityId,
  });
  factory School.fromMap(Map<String, Object?> map) => School(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        municipalityId: map['municipality_id']?.toString(),
      );
}

class Language {
  final String id;
  final String name;
  final String type;
  const Language({required this.id, required this.name, required this.type});
  factory Language.fromMap(Map<String, Object?> map) => Language(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        type: map['type']?.toString() ?? '',
      );
}

class CareerCatalog {
  final String id;
  final String name;
  final String description;
  final String hollandCode;
  final String department;
  final String websiteUrl;
  final Map<String, double> weights;
  final List<int> questionIds;

  const CareerCatalog({
    required this.id,
    required this.name,
    required this.description,
    required this.hollandCode,
    required this.department,
    this.websiteUrl = '',
    required this.weights,
    required this.questionIds,
  });
}

class DepartmentQuestion {
  final String department;
  final String questionText;

  const DepartmentQuestion({
    required this.department,
    required this.questionText,
  });

  factory DepartmentQuestion.fromMap(Map<String, Object?> map) =>
      DepartmentQuestion(
        department: map['department']?.toString() ?? '',
        questionText: map['question_text']?.toString() ?? '',
      );
}
