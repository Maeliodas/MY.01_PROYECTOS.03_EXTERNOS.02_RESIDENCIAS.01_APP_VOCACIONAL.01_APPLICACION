import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/avatar_config.dart';

/// Lista de avatares predefinidos (rutas de assets)
const List<String> defaultAvatars = [
  'assets/avatars/avatar_1.png',
  'assets/avatars/avatar_2.png',
  'assets/avatars/avatar_3.png',
  'assets/avatars/avatar_4.png',
  'assets/avatars/avatar_5.png',
  'assets/avatars/avatar_6.png',
];

class AvatarNotifier extends Notifier<AvatarConfig> {
  @override
  AvatarConfig build() {
    return AvatarConfig.initial();
  }

  /// Selecciona un avatar predefinido
  void selectAvatar(String avatarPath) {
    final id = avatarPath.split('/').last.replaceAll('.png', '');
    state = state.copyWith(baseAvatarId: id, avatarPath: avatarPath);
  }

  void updateHair(String hairStyle) {
    state = state.copyWith(hairStyle: hairStyle);
  }

  void updateHairColor(String hairColor) {
    state = state.copyWith(hairColor: hairColor);
  }

  void updateOutfit(String outfit) {
    state = state.copyWith(outfit: outfit);
  }

  void updateAccessory(String accessory) {
    state = state.copyWith(accessory: accessory);
  }

  void updateSkinTone(String skinTone) {
    state = state.copyWith(skinTone: skinTone);
  }

  void resetCustomization() {
    state = state.copyWith(
      hairStyle: 'default',
      hairColor: 'black',
      outfit: 'student',
      accessory: 'none',
      skinTone: 'medium',
    );
  }
}

final avatarProvider = NotifierProvider<AvatarNotifier, AvatarConfig>(
  AvatarNotifier.new,
);
