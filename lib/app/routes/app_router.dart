import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile_setup/presentation/pages/personal_data_page.dart';
import '../../features/profile_setup/presentation/pages/school_data_page.dart';
import '../../features/avatar/presentation/pages/choose_avatar_page.dart';
import '../../features/test/presentation/pages/test_intro_page.dart';
import '../../features/test/presentation/pages/test_page.dart';
import '../../features/test/presentation/pages/test_progress_tree_page.dart';
import '../../features/result/presentation/pages/result_unlocked_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const PersonalDataPage(),
      ),
      GoRoute(
        path: '/school-data',
        builder: (context, state) => const SchoolDataPage(),
      ),
      GoRoute(
        path: '/choose-avatar',
        builder: (context, state) => const ChooseAvatarPage(),
      ),
      GoRoute(
        path: '/test-intro',
        builder: (context, state) => const TestIntroPage(),
      ),
      GoRoute(
        path: '/test-progress-tree',
        builder: (context, state) => const TestProgressTreePage(),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => const TestPage(),
      ),
      GoRoute(
        path: '/result-unlocked',
        builder: (context, state) => const ResultUnlockedPage(),
      ),
    ],
  );
});
