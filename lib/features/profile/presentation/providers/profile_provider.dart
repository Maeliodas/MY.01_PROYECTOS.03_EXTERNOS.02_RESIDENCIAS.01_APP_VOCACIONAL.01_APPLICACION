import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(null) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = await _repository.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = profile;
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
