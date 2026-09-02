import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());
final profileProvider = FutureProvider<UserProfile?>(
  (ref) => ref.read(profileRepositoryProvider).get(),
);
final catalogSchoolsProvider = FutureProvider(
  (ref) => ref.read(profileRepositoryProvider).schools(),
);
final catalogLanguagesProvider = FutureProvider(
  (ref) => ref.read(profileRepositoryProvider).languages(),
);
