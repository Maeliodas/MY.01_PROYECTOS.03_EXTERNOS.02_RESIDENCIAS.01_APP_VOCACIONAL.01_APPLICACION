//import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/avatar/presentation/pages/choose_avatar_page.dart';
import '../../features/avatar/presentation/pages/simple_avatar_editor_page.dart';
import '../../features/profile_setup/presentation/pages/personal_data_page.dart';
import '../../features/profile_setup/presentation/pages/school_data_page.dart';
import '../../features/test/presentation/pages/test_intro_page.dart';
import '../../features/test/presentation/pages/test_page.dart';
import '../../features/test/presentation/pages/test_progress_tree_page.dart';
import '../../features/test/presentation/pages/open_question_page.dart';
import '../../features/test/presentation/pages/thank_you_page.dart';
import '../../features/result/presentation/pages/result_unlocked_page.dart';
import '../../features/result/presentation/pages/result_detail_page.dart';
import '../../features/result/presentation/pages/career_ranking_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/history/presentation/pages/test_history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/path/presentation/pages/path_home_page.dart';
import '../../features/path/presentation/pages/contact_institute_page.dart';
import '../../features/path/presentation/pages/missions_page.dart';
import '../../features/common/presentation/pages/error_page.dart';

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
        path: '/choose-avatar',
        builder: (context, state) => const ChooseAvatarPage(),
      ),
      GoRoute(
        path: '/avatar-editor',
        builder: (context, state) => const SimpleAvatarEditorPage(),
      ),
      GoRoute(
        path: '/personal-data',
        builder: (context, state) => const PersonalDataPage(),
      ),
      GoRoute(
        path: '/school-data',
        builder: (context, state) => const SchoolDataPage(),
      ),
      GoRoute(
        path: '/test-intro',
        builder: (context, state) => const TestIntroPage(),
      ),
      GoRoute(
        path: '/test-tree',
        builder: (context, state) => const TestProgressTreePage(),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => const TestPage(),
      ),
      GoRoute(
        path: '/open-question',
        builder: (context, state) => const OpenQuestionPage(),
      ),
      GoRoute(
        path: '/thank-you',
        builder: (context, state) => const ThankYouPage(),
      ),
      GoRoute(
        path: '/result-unlocked',
        builder: (context, state) => const ResultUnlockedPage(),
      ),
      GoRoute(
        path: '/result-detail',
        builder: (context, state) => const ResultDetailPage(),
      ),
      GoRoute(
        path: '/career-ranking',
        builder: (context, state) => const CareerRankingPage(),
      ),
      GoRoute(
        path: '/path-home',
        builder: (context, state) => const PathHomePage(),
      ),
      GoRoute(
        path: '/contact-institute',
        builder: (context, state) => const ContactInstitutePage(),
      ),
      GoRoute(
        path: '/missions',
        builder: (context, state) => const MissionsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const TestHistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => const ErrorPage(),
      ),
    ],
  );
});
