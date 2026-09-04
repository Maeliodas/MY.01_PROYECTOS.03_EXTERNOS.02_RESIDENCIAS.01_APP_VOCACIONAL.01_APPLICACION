import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/path/presentation/pages/path_shell_page.dart';
import '../../features/path/presentation/pages/progress_map_page.dart';
import '../../features/result/presentation/pages/results_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile_setup/presentation/pages/profile_setup_page.dart';
import '../../features/avatar/presentation/pages/avatar_customization_page.dart';
import '../../features/test/presentation/pages/test_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/map',
  routes: [
    GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupPage()),
    GoRoute(path: '/avatar-customization', builder: (_, __) => const AvatarCustomizationPage()),
    GoRoute(path: '/test', builder: (_, __) => const TestPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => PathShellPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/map', builder: (_, __) => const ProgressMapPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/results', builder: (_, __) => const ResultsPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ]),
      ],
    ),
  ],
));
