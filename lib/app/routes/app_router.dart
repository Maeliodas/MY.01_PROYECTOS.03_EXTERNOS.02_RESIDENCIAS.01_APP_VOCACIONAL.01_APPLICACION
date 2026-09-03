import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/result/presentation/pages/career_ranking_page.dart';
import '../../features/result/presentation/pages/result_detail_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/career-ranking',
      builder: (context, state) => const CareerRankingPage(),
    ),
    GoRoute(
      path: '/result-detail',
      builder: (context, state) {
        final careerName =
            state.extra as String? ?? 'Ingeniería en Sistemas Computacionales';
        return ResultDetailPage(careerName: careerName);
      },
    ),
  ],
);
