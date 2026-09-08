class School {
  final String id;
  final String name;
  const School({required this.id, required this.name});
  factory School.fromMap(Map<String, Object?> map) => School(id: map['id'] as String, name: map['name'] as String);
}

class Language {
  final String id;
  final String name;
  final String type;
  const Language({required this.id, required this.name, required this.type});
  factory Language.fromMap(Map<String, Object?> map) => Language(id: map['id'] as String, name: map['name'] as String, type: map['type'] as String);
}
