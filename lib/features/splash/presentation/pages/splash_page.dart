import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
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
    // El splash permanece visible al menos 3 segundos, mientras SQLite se
    // consulta en paralelo. Si la carga local tarda más, no se agrega una
    // espera artificial adicional.
    final results = await Future.wait<Object?>([
      ref.read(profileRepositoryProvider).getProfile(),
      Future<void>.delayed(AppConstants.splashDuration),
    ]);
    final profile = results.first;
    if (!mounted) return;

    context.go(profile == null ? '/onboarding' : '/path-home');

    // La sincronización de catálogos se ejecuta en segundo plano. Un fallo de
    // red no debe impedir que el usuario entre a la aplicación.
    unawaited(_syncCatalogsInBackground());
  }

  Future<void> _syncCatalogsInBackground() async {
    try {
      await ref.read(catalogSyncServiceProvider).sync();
      if (!mounted) return;
      ref.invalidate(statesProvider);
      ref.invalidate(allLanguagesProvider);
      ref.invalidate(careersCatalogProvider);
    } catch (error, stackTrace) {
      debugPrint('No se pudieron sincronizar los catálogos: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF071E17), Color(0xFF0A2B20), Color(0xFF071812)]
                : const [Color(0xFFF7FFE9), Color(0xFFF3F8E7), Color(0xFFE9FFF8)],
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF0D382A) : Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: dark ? .35 : .12),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              dark
                                  ? 'assets/branding/app_logo_dark.png'
                                  : 'assets/branding/app_logo_light.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -12,
                          top: -14,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF4A2875) : const Color(0xFFD7B8FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: dark ? const Color(0xFFE2C4FF) : const Color(0xFF6E26C8),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -.6,
                        color: dark ? Colors.white : const Color(0xFF00923F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DESCUBRE TU CAMINO',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.1,
                        color: dark ? const Color(0xFF9ED9B7) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: dark ? .88 : 1.0,
                      child: Image.asset(
                        'assets/institution/tecnm_ittux_wordmark.png',
                        width: 210,
                        fit: BoxFit.contain,
                      ),
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