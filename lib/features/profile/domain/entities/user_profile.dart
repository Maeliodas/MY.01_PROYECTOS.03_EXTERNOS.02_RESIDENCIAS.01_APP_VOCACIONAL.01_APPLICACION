class UserProfile {
  final String name, avatarId;
  final int? age;
  final String? gender, schoolId, schoolNameSnapshot, otherLanguage;
  final List<String> languageIds, languageNamesSnapshot;
  const UserProfile({
    required this.name,
    this.age,
    this.gender,
    this.schoolId,
    this.schoolNameSnapshot,
    this.languageIds = const [],
    this.languageNamesSnapshot = const [],
    this.otherLanguage,
    this.avatarId = '',
  });
  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    String? schoolId,
    String? schoolNameSnapshot,
    List<String>? languageIds,
    List<String>? languageNamesSnapshot,
    String? otherLanguage,
    String? avatarId,
  }) => UserProfile(
    name: name ?? this.name,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    schoolId: schoolId ?? this.schoolId,
    schoolNameSnapshot: schoolNameSnapshot ?? this.schoolNameSnapshot,
    languageIds: languageIds ?? this.languageIds,
    languageNamesSnapshot: languageNamesSnapshot ?? this.languageNamesSnapshot,
    otherLanguage: otherLanguage ?? this.otherLanguage,
    avatarId: avatarId ?? this.avatarId,
  );
  Map<String, dynamic> snapshot() => {
    'schoolId': schoolId,
    'schoolName': schoolNameSnapshot,
    'gender': gender,
    'languageIds': languageIds,
    'languageNames': languageNamesSnapshot,
  };
}
