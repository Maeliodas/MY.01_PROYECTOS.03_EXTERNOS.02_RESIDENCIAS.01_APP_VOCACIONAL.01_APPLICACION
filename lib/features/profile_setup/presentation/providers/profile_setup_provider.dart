import 'package:flutter_riverpod/flutter_riverpod.dart';

class Setup {
  final String name;
  final int? age;
  final String? gender, schoolId, schoolName, otherLanguage;
  final List<String> languageIds, languageNames;

  const Setup({
    this.name = '',
    this.age,
    this.gender,
    this.schoolId,
    this.schoolName,
    this.otherLanguage,
    this.languageIds = const [],
    this.languageNames = const [],
  });

  Setup copyWith({
    String? name,
    int? age,
    String? gender,
    String? schoolId,
    String? schoolName,
    String? otherLanguage,
    List<String>? languageIds,
    List<String>? languageNames,
  }) =>
      Setup(
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        schoolId: schoolId ?? this.schoolId,
        schoolName: schoolName ?? this.schoolName,
        otherLanguage: otherLanguage ?? this.otherLanguage,
        languageIds: languageIds ?? this.languageIds,
        languageNames: languageNames ?? this.languageNames,
      );
}

final profileSetupProvider = StateProvider<Setup>((ref) => const Setup());
