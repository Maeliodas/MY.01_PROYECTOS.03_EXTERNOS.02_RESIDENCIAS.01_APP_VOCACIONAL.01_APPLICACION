import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends Notifier<UserProfile?> {
  late final ProfileRepository _repository;

  @override
  UserProfile? build() {
    _repository = ref.watch(profileRepositoryProvider);
    // Carga inicial asíncrona
    Future.microtask(() => loadProfile());
    return null; // estado inicial mientras carga
  }

  Future<void> loadProfile() async {
    final profile = await _repository.getProfile();
    state = profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = profile;
  }

  Future<void> clearProfile() async {
    // Si más adelante implementas borrado en el repositorio
    state = null;
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
