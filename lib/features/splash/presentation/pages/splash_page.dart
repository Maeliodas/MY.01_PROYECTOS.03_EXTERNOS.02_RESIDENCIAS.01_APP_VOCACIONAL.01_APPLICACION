import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(seconds: 2));
    final profile = await ref.read(profileRepositoryProvider).getProfile();

    if (mounted) {
      if (profile != null) {
        context.go('/path-home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.explore, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aevum Iter',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              'DESCUBRE TU CAMINO',
              style: TextStyle(
                  fontSize: 12, letterSpacing: 1.5, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
