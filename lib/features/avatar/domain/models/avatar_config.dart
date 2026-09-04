import 'dart:convert';

class AvatarConfig {
  final String baseAvatarId;
  final String avatarPath;
  final String hairStyle;
  final String hairColor;
  final String outfit;
  final String accessory;
  final String skinTone;

  const AvatarConfig({
    required this.baseAvatarId,
    required this.avatarPath,
    this.hairStyle = 'default',
    this.hairColor = 'black',
    this.outfit = 'student',
    this.accessory = 'none',
    this.skinTone = 'medium',
  });

  factory AvatarConfig.initial() {
    return const AvatarConfig(
      baseAvatarId: 'avatar_1',
      avatarPath: 'assets/avatars/avatar_1.png',
    );
  }

  AvatarConfig copyWith({
    String? baseAvatarId,
    String? avatarPath,
    String? hairStyle,
    String? hairColor,
    String? outfit,
    String? accessory,
    String? skinTone,
  }) {
    return AvatarConfig(
      baseAvatarId: baseAvatarId ?? this.baseAvatarId,
      avatarPath: avatarPath ?? this.avatarPath,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      outfit: outfit ?? this.outfit,
      accessory: accessory ?? this.accessory,
      skinTone: skinTone ?? this.skinTone,
    );
  }

  // ---------- Map (útil para SQLite) ----------
  Map<String, dynamic> toMap() {
    return {
      'baseAvatarId': baseAvatarId,
      'avatarPath': avatarPath,
      'hairStyle': hairStyle,
      'hairColor': hairColor,
      'outfit': outfit,
      'accessory': accessory,
      'skinTone': skinTone,
    };
  }

  factory AvatarConfig.fromMap(Map<String, dynamic> map) {
    return AvatarConfig(
      baseAvatarId: map['baseAvatarId'] as String? ?? 'avatar_1',
      avatarPath: map['avatarPath'] as String? ?? 'assets/avatars/avatar_1.png',
      hairStyle: map['hairStyle'] as String? ?? 'default',
      hairColor: map['hairColor'] as String? ?? 'black',
      outfit: map['outfit'] as String? ?? 'student',
      accessory: map['accessory'] as String? ?? 'none',
      skinTone: map['skinTone'] as String? ?? 'medium',
    );
  }

  // ---------- JSON (lo que usa UserProfile) ----------
  String toJson() => jsonEncode(toMap());

  factory AvatarConfig.fromJson(String source) {
    if (source.isEmpty) return AvatarConfig.initial();
    final map = jsonDecode(source) as Map<String, dynamic>;
    return AvatarConfig.fromMap(map);
  }
}
