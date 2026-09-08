import '../../../avatar/domain/models/avatar_config.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String state;
  // final String municipality;
  final String school;
  final bool speaksLanguages;
  final List<String> languagesList;
  final AvatarConfig avatarConfig;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.state,
    // required this.municipality,
    required this.school,
    required this.speaksLanguages,
    required this.languagesList,
    required this.avatarConfig,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'state': state,
      // 'municipality': municipality,
      'school': school,
      'speaks_languages': speaksLanguages ? 1 : 0,
      'languages_list': languagesList.join(','),
      'avatar_config_json': avatarConfig.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      state: map['state'] as String? ?? 'No especificado',
      // municipality: map['municipality'] as String? ?? 'No especificado',
      school: map['school'] as String? ?? 'No especificada',
      speaksLanguages: map['speaks_languages'] == 1,
      languagesList: (map['languages_list'] as String).isNotEmpty
          ? (map['languages_list'] as String).split(',')
          : [],
      avatarConfig: AvatarConfig.fromJson(map['avatar_config_json']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
