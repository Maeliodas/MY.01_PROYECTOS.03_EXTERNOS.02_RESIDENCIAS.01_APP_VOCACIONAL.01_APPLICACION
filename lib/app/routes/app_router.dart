import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile_setup/presentation/pages/personal_data_page.dart';
import '../../features/profile_setup/presentation/pages/school_data_page.dart';
import '../../features/avatar/presentation/pages/choose_avatar_page.dart';
import '../../features/avatar/presentation/pages/simple_avatar_editor_page.dart';
import '../../features/path/presentation/pages/path_home_page.dart';
import '../../features/test/presentation/pages/test_intro_page.dart';
import '../../features/test/presentation/pages/test_page.dart';
import '../../features/test/presentation/pages/open_question_page.dart';
import '../../features/test/presentation/pages/thank_you_page.dart';
import '../../features/result/presentation/pages/result_unlocked_page.dart';
import '../../features/result/presentation/pages/result_analysis_page.dart';
import '../../features/result/presentation/pages/career_ranking_page.dart';
import '../../features/result/presentation/pages/result_detail_page.dart';
import '../../features/result/presentation/pages/career_info_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/history/presentation/pages/test_history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(
        path: '/personal-data', builder: (_, __) => const PersonalDataPage()),
    GoRoute(path: '/school-data', builder: (_, __) => const SchoolDataPage()),
    GoRoute(
        path: '/choose-avatar', builder: (_, __) => const ChooseAvatarPage()),
    GoRoute(
        path: '/avatar-editor',
        builder: (_, __) => const SimpleAvatarEditorPage()),
    GoRoute(
      path: '/path-home',
      builder: (_, state) => PathHomePage(
        initialIndex: int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0,
      ),
    ),
    GoRoute(path: '/test-intro', builder: (_, __) => const TestIntroPage()),
    GoRoute(path: '/test', builder: (_, __) => const TestPage()),
    GoRoute(
        path: '/open-question', builder: (_, __) => const OpenQuestionPage()),
    GoRoute(path: '/thank-you', builder: (_, __) => const ThankYouPage()),
    GoRoute(
        path: '/result-analysis',
        builder: (_, __) => const ResultAnalysisPage()),
    GoRoute(
        path: '/result-unlocked',
        builder: (_, __) => const ResultUnlockedPage()),
    GoRoute(
        path: '/career-ranking', builder: (_, __) => const CareerRankingPage()),
    GoRoute(
        path: '/result-detail', builder: (_, __) => const ResultDetailPage()),
    GoRoute(
      path: '/career-info',
      builder: (context, state) {
        final extra = state.extra;
        String careerId = '';
        String name = 'Carrera';
        double? affinity;
        int? rank;
        if (extra is Map) {
          careerId = extra['careerId']?.toString() ?? '';
          name = extra['name']?.toString() ?? 'Carrera';
          final a = extra['affinity'];
          if (a is num) affinity = a.toDouble();
          final r = extra['rank'];
          if (r is int) rank = r;
          if (r is num) rank = r.toInt();
        }
        return CareerInfoPage(
          careerId: careerId,
          careerName: name,
          affinity: affinity,
          rank: rank,
        );
      },
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfilePage()),
    GoRoute(path: '/history', builder: (_, __) => const TestHistoryPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  ],
);
