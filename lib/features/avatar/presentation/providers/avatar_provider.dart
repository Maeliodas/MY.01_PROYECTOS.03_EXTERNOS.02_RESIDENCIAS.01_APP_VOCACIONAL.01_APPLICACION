import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/avatar_config.dart';

/// Lista de avatares predefinidos (rutas de assets)[cite: 1]
const List<String> defaultAvatars = [
  'assets/avatars/avatar_01.png',
  'assets/avatars/avatar_02.png',
  'assets/avatars/avatar_03.png',
  'assets/avatars/avatar_04.png',
  'assets/avatars/avatar_05.png',
  'assets/avatars/avatar_06.png',
];

class AvatarNotifier extends Notifier<AvatarConfig> {
  @override
  AvatarConfig build() {
    return AvatarConfig.initial(); //[cite: 1, 5]
  }

  /// Selecciona un avatar predefinido desde la parrilla[cite: 1, 3]
  void selectAvatar(String avatarPath) {
    final id = avatarPath.split('/').last.replaceAll('.png', '');
    state =
        state.copyWith(baseAvatarId: id, avatarPath: avatarPath); //[cite: 1, 5]
  }

  void updateHair(String hairStyle) {
    state = state.copyWith(hairStyle: hairStyle); //[cite: 1, 5]
  }

  void updateHairColor(String hairColor) {
    state = state.copyWith(hairColor: hairColor); //[cite: 1, 5]
  }

  void updateOutfit(String outfit) {
    state = state.copyWith(outfit: outfit); //[cite: 1, 5]
  }

  void updateAccessory(String accessory) {
    state = state.copyWith(accessory: accessory); //[cite: 1, 5]
  }

  void updateSkinTone(String skinTone) {
    state = state.copyWith(skinTone: skinTone); //[cite: 1, 5]
  }

  void resetCustomization() {
    state = AvatarConfig.initial(); //[cite: 1, 5]
  }
}

final avatarProvider = NotifierProvider<AvatarNotifier, AvatarConfig>(
  AvatarNotifier.new, //[cite: 1]
);
