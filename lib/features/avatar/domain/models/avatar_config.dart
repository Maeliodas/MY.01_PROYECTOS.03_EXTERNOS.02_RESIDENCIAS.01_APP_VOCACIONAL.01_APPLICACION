import 'dart:convert';

class AvatarConfig {
  final String avatarPath;
  final String hairStyle;
  final String clothesStyle;
  final String accessory;
  final String colorHex;

  AvatarConfig({
    required this.avatarPath,
    this.hairStyle = 'default',
    this.clothesStyle = 'default',
    this.accessory = 'none',
    this.colorHex = '67A94F',
  });

  AvatarConfig copyWith({
    String? avatarPath,
    String? hairStyle,
    String? clothesStyle,
    String? accessory,
    String? colorHex,
  }) {
    return AvatarConfig(
      avatarPath: avatarPath ?? this.avatarPath,
      hairStyle: hairStyle ?? this.hairStyle,
      clothesStyle: clothesStyle ?? this.clothesStyle,
      accessory: accessory ?? this.accessory,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatarPath': avatarPath,
      'hairStyle': hairStyle,
      'clothesStyle': clothesStyle,
      'accessory': accessory,
      'colorHex': colorHex,
    };
  }

  factory AvatarConfig.fromMap(Map<String, dynamic> map) {
    return AvatarConfig(
      avatarPath: map['avatarPath'] ?? 'assets/avatars/avatar_1.png',
      hairStyle: map['hairStyle'] ?? 'default',
      clothesStyle: map['clothesStyle'] ?? 'default',
      accessory: map['accessory'] ?? 'none',
      colorHex: map['colorHex'] ?? '67A94F',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AvatarConfig.fromJson(String source) =>
      AvatarConfig.fromMap(jsonDecode(source));
}
