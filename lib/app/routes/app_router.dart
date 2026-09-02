import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile_setup/presentation/pages/personal_data_page.dart';
import '../../features/profile_setup/presentation/pages/school_data_page.dart';
import '../../features/avatar/presentation/pages/choose_avatar_page.dart';
import '../../features/avatar/presentation/pages/simple_avatar_editor_page.dart';
import '../../features/test/presentation/pages/test_intro_page.dart';
import '../../features/test/presentation/pages/test_page.dart';
import '../../features/test/presentation/pages/test_progress_tree_page.dart';
import '../../features/test/presentation/pages/open_question_page.dart';
import '../../features/result/presentation/pages/result_unlocked_page.dart';
import '../../features/result/presentation/pages/result_detail_page.dart';
import '../../features/result/presentation/pages/career_ranking_page.dart';
import '../../features/history/presentation/pages/test_history_page.dart';
import '../../features/path/presentation/pages/path_home_page.dart';
import '../../features/path/presentation/pages/contact_institute_page.dart';
import '../../features/path/presentation/pages/missions_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/common/presentation/pages/error_page.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    errorBuilder: (c, s) => ErrorPage(message: s.error?.toString()),
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
      GoRoute(
        path: '/profile/personal',
        builder: (c, s) => const PersonalDataPage(),
      ),
      GoRoute(
        path: '/profile/school',
        builder: (c, s) => const SchoolDataPage(),
      ),
      GoRoute(path: '/avatar', builder: (c, s) => const ChooseAvatarPage()),
      GoRoute(
        path: '/avatar/editor',
        builder: (c, s) => const SimpleAvatarEditorPage(),
      ),
      GoRoute(path: '/test/intro', builder: (c, s) => const TestIntroPage()),
      GoRoute(path: '/test', builder: (c, s) => const TestPage()),
      GoRoute(
        path: '/test/progress',
        builder: (c, s) => const TestProgressTreePage(),
      ),
      GoRoute(
        path: '/test/open-question',
        builder: (c, s) => const OpenQuestionPage(),
      ),
      GoRoute(
        path: '/result/unlocked',
        builder: (c, s) => const ResultUnlockedPage(),
      ),
      GoRoute(
        path: '/result/detail',
        builder: (c, s) => const ResultDetailPage(),
      ),
      GoRoute(
        path: '/result/careers',
        builder: (c, s) => const CareerRankingPage(),
      ),
      GoRoute(path: '/history', builder: (c, s) => const TestHistoryPage()),
      GoRoute(path: '/path', builder: (c, s) => const PathHomePage()),
      GoRoute(
        path: '/path/contact',
        builder: (c, s) => const ContactInstitutePage(),
      ),
      GoRoute(path: '/path/missions', builder: (c, s) => const MissionsPage()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
      GoRoute(
        path: '/profile/edit',
        builder: (c, s) => const EditProfilePage(),
      ),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
    ],
  ),
);
