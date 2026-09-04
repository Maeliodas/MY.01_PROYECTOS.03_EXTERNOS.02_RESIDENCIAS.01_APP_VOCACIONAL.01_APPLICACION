class AvatarConfig {
  final String baseAvatarId;
  final String hairStyle;
  final String hairColor;
  final String outfit;
  final String accessory;
  final String skinTone;

  const AvatarConfig({
    required this.baseAvatarId,
    required this.hairStyle,
    required this.hairColor,
    required this.outfit,
    required this.accessory,
    required this.skinTone,
  });

  AvatarConfig copyWith({String? hairStyle, String? hairColor, String? outfit, String? accessory, String? skinTone}) =>
    AvatarConfig(
      baseAvatarId: baseAvatarId,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      outfit: outfit ?? this.outfit,
      accessory: accessory ?? this.accessory,
      skinTone: skinTone ?? this.skinTone,
    );
}
