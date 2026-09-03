import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/avatar_config.dart';

final defaultAvatars = [
  'assets/avatars/avatar_1.png',
  'assets/avatars/avatar_2.png',
  'assets/avatars/avatar_3.png',
  'assets/avatars/avatar_4.png',
  'assets/avatars/avatar_5.png',
  'assets/avatars/avatar_6.png',
];

class AvatarNotifier extends StateNotifier<AvatarConfig> {
  AvatarNotifier()
      : super(AvatarConfig(avatarPath: 'assets/avatars/avatar_1.png'));

  void selectAvatar(String path) {
    state = state.copyWith(avatarPath: path);
  }

  void updateHair(String hair) {
    state = state.copyWith(hairStyle: hair);
  }

  void updateClothes(String clothes) {
    state = state.copyWith(clothesStyle: clothes);
  }

  void updateAccessory(String accessory) {
    state = state.copyWith(accessory: accessory);
  }

  void updateColor(String hex) {
    state = state.copyWith(colorHex: hex);
  }
}

final avatarProvider =
    StateNotifierProvider<AvatarNotifier, AvatarConfig>((ref) {
  return AvatarNotifier();
});
