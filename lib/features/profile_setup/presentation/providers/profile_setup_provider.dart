import 'package:flutter_riverpod/flutter_riverpod.dart';

class Setup {
  final String name;
  final int? age;
  final String? gender;
  final String? schoolId;
  final String? schoolName;
  final String? otherLanguage;
  final List<String> languageIds;
  final List<String> languageNames;

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
  }) {
    return Setup(
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
}

class ProfileSetupNotifier extends Notifier<Setup> {
  @override
  Setup build() => const Setup();

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateAge(int? age) {
    state = state.copyWith(age: age);
  }

  void updateGender(String? gender) {
    state = state.copyWith(gender: gender);
  }

  void updateSchool({String? schoolId, String? schoolName}) {
    state = state.copyWith(schoolId: schoolId, schoolName: schoolName);
  }

  void updateLanguages({
    List<String>? languageIds,
    List<String>? languageNames,
    String? otherLanguage,
  }) {
    state = state.copyWith(
      languageIds: languageIds,
      languageNames: languageNames,
      otherLanguage: otherLanguage,
    );
  }

  void reset() {
    state = const Setup();
  }
}

final profileSetupProvider = NotifierProvider<ProfileSetupNotifier, Setup>(
  ProfileSetupNotifier.new,
);
