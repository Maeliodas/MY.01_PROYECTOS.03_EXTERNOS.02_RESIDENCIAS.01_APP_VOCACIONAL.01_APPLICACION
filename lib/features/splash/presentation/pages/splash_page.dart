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
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    if (!mounted) return;
    context.go(profile == null ? '/onboarding' : '/path-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7FFE9), Color(0xFFF3F8E7), Color(0xFFE9FFF8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 154,
                          height: 122,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.primary, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 18, offset: const Offset(0, 8))],
                          ),
                          child: const Icon(Icons.explore_rounded, size: 68, color: Color(0xFF287400)),
                        ),
                        Positioned(
                          right: -12,
                          top: -14,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(color: Color(0xFFD7B8FF), shape: BoxShape.circle),
                            child: const Icon(Icons.school_rounded, color: Color(0xFF6E26C8), size: 25),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text('Aevum Iter', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: -.8)),
                    const SizedBox(height: 3),
                    const Text('DESCUBRE TU CAMINO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: Color(0xFF4E5148))),
                  ],
                ),
              ),
              Positioned(
                bottom: 38,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary)),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), borderRadius: BorderRadius.circular(28)),
                      child: const Text('●  TECNM TUXTEPEC', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.4, color: Color(0xFF30342E))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
