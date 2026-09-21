import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool loadFailed = false;
  String status = 'Cargando…';

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    if (mounted) setState(() => loadFailed = false);
    try {
      // El splash permanece visible al menos 3 segundos, mientras en paralelo
      // se lee el perfil local y se intenta sincronizar catálogos (acotado).
      // Sincronizar ANTES de navegar garantiza que la primera pantalla ya vea
      // los datos nuevos del panel sin necesitar una segunda apertura.
      final results = await Future.wait<Object?>([
        ref.read(profileRepositoryProvider).getProfile(),
        Future<void>.delayed(AppConstants.splashDuration),
        _syncCatalogsBounded(),
      ]).timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException(
          'La base local tardó demasiado en responder',
        ),
      );
      final profile = results.first;
      final synced = results[2] == true;
      if (!mounted) return;

      _refreshCatalogProviders();
      context.go(profile == null ? '/onboarding' : '/path-home');

      // Si el intento acotado no alcanzó (red lenta), un reintento en fondo.
      // Un fallo de red no debe impedir que el usuario entre a la aplicación.
      if (!synced) unawaited(_syncCatalogsInBackground());
    } catch (error) {
      debugPrint('Splash: no se pudo cargar ($error)');
      if (mounted) setState(() => loadFailed = true);
    }
  }

  /// Intento de sincronización acotado: nunca lanza, devuelve si aplicó.
  Future<bool> _syncCatalogsBounded() async {
    try {
      if (mounted) setState(() => status = 'Actualizando catálogos…');
      return await ref
          .read(catalogSyncServiceProvider)
          .sync()
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return false;
    } finally {
      if (mounted) setState(() => status = 'Cargando…');
    }
  }

  void _refreshCatalogProviders() {
    ref.invalidate(statesProvider);
    ref.invalidate(schoolsProvider);
    ref.invalidate(allLanguagesProvider);
    ref.invalidate(careersCatalogProvider);
    ref.invalidate(departmentQuestionsProvider);
  }

  Future<void> _syncCatalogsInBackground() async {
    try {
      final ok = await ref.read(catalogSyncServiceProvider).sync();
      if (!mounted || !ok) return;
      _refreshCatalogProviders();
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
                    if (loadFailed) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'No se pudo cargar la información local. Revisa el almacenamiento e inténtalo de nuevo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: PrimaryButton(
                          text: 'Reintentar',
                          icon: Icons.refresh_rounded,
                          onPressed: _go,
                        ),
                      ),
                    ] else
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.8,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 22),
                    if (!loadFailed)
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: .55),
                        ),
                      ),
                    if (!loadFailed) const SizedBox(height: 8),
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