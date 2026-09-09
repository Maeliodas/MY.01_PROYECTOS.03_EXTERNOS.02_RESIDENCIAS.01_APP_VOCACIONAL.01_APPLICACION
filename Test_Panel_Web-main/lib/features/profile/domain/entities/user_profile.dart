import 'dart:convert';

import '../../../avatar/domain/models/avatar_config.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String? stateId;
  final String state;
  final String? municipalityId;
  final String municipality;
  final String? schoolId;
  final String school;
  final bool speaksLanguages;
  final List<String> languageIds;
  final List<String> languagesList;
  final AvatarConfig avatarConfig;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.stateId,
    required this.state,
    this.municipalityId,
    required this.municipality,
    this.schoolId,
    required this.school,
    required this.speaksLanguages,
    this.languageIds = const [],
    required this.languagesList,
    required this.avatarConfig,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    String? stateId,
    String? state,
    String? municipalityId,
    String? municipality,
    String? schoolId,
    String? school,
    bool? speaksLanguages,
    List<String>? languageIds,
    List<String>? languagesList,
    AvatarConfig? avatarConfig,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      stateId: stateId ?? this.stateId,
      state: state ?? this.state,
      municipalityId: municipalityId ?? this.municipalityId,
      municipality: municipality ?? this.municipality,
      schoolId: schoolId ?? this.schoolId,
      school: school ?? this.school,
      speaksLanguages: speaksLanguages ?? this.speaksLanguages,
      languageIds: languageIds ?? this.languageIds,
      languagesList: languagesList ?? this.languagesList,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'state_id': stateId,
      'state': state,
      'municipality_id': municipalityId,
      'municipality': municipality,
      'school_id': schoolId,
      'school': school,
      'speaks_languages': speaksLanguages ? 1 : 0,
      'languages_list': languagesList.join(','),
      'avatar_config_json': avatarConfig.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(
    Map<String, dynamic> map, {
    List<String> languageIds = const [],
  }) {
    final rawLanguages = map['languages_list']?.toString() ?? '';
    return UserProfile(
      id: map['id']?.toString() ?? '1',
      name: map['name']?.toString() ?? 'Aspirante',
      age: (map['age'] as num?)?.toInt() ?? 18,
      gender: map['gender']?.toString() ?? 'Otro',
      stateId: map['state_id']?.toString(),
      state: map['state']?.toString() ?? 'No especificado',
      municipalityId: map['municipality_id']?.toString(),
      municipality: map['municipality']?.toString() ?? 'No especificado',
      schoolId: map['school_id']?.toString(),
      school: map['school']?.toString() ?? 'No especificada',
      speaksLanguages: map['speaks_languages'] == 1,
      languageIds: languageIds,
      languagesList: rawLanguages.isEmpty ? const [] : rawLanguages.split(','),
      avatarConfig: AvatarConfig.fromJson(
        _normalizeAvatarJson(map['avatar_config_json']),
      ),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static String _normalizeAvatarJson(dynamic value) {
    if (value == null) return '{}';
    if (value is String) return value;
    return jsonEncode(value);
  }
}
