import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/presentation/pages/privacy_page.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/institutional_logos.dart';

class _OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  const _OnboardingItem(this.title, this.description, this.icon, this.accent);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int index = 0;

  final pages = const [
    _OnboardingItem(
        'Tu futuro empieza\naquí',
        'Descubre qué carrera del TecNM Tuxtepec es para ti.',
        Icons.landscape_rounded,
        AppColors.primary),
    _OnboardingItem(
        'Aprende sobre ti',
        'Evaluamos tus intereses y habilidades con un divertido test.',
        Icons.lightbulb_rounded,
        AppColors.secondary),
    _OnboardingItem(
        'Logra tus metas',
        'Evita la deserción y elige el camino que te apasiona.',
        Icons.emoji_events_rounded,
        AppColors.blue400),
  ];

  void next() {
    if (index == pages.length - 1) {
      context.go('/choose-avatar');
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [AppColors.backgroundDark, AppColors.blue900]
                  : const [AppColors.white, AppColors.blue50]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      AppBackButton(
                          onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOut)),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(AppConstants.appName,
                            style: AppTypography.headline.copyWith(
                                fontSize: 18,
                                color: dark
                                    ? AppColors.primaryOnDark
                                    : AppColors.primary)),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () => context.go('/choose-avatar'),
                        child: Text('SALTAR',
                            style: AppTypography.bodyStrong.copyWith(
                                color: dark
                                    ? AppColors.primaryOnDark
                                    : AppColors.primary,
                                letterSpacing: 1))),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (v) => setState(() => index = v),
                    itemBuilder: (_, i) {
                      final p = pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _OnboardingArtwork(
                            step: i,
                            icon: p.icon,
                            accent: p.accent,
                            dark: dark,
                          ),
                          const SizedBox(height: 30),
                          Text(p.title,
                              textAlign: TextAlign.center,
                              style: AppTypography.display.copyWith(
                                  fontSize: 34,
                                  height: 1.02,
                                  color: dark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(p.description,
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(
                                    fontSize: 17,
                                    height: 1.4,
                                    color: dark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: i == index ? 34 : 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                                color: i == index
                                    ? AppColors.primary
                                    : (dark
                                        ? AppColors.borderDark
                                        : AppColors.borderGray),
                                borderRadius: BorderRadius.circular(
                                    AppMetrics.radiusChip)),
                          )),
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                    text: index == pages.length - 1 ? '¡Empezar!' : 'Continuar',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: next),
                const SizedBox(height: 8),
                TextButton.icon(
                    onPressed: () => showPrivacyNoticeDialog(context),
                    icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                    label: const Text('Aviso de privacidad')),
                const SizedBox(height: 26),
                const InstitutionalFooter(scale: .78, showNames: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MiniBadge({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .25), blurRadius: 12)
            ]),
        child: Icon(icon, color: AppColors.onPrimary, size: 24),
      );
}

/// Ilustración destacada por paso: panel a todo lo ancho con gradiente del
/// acento del paso, círculos decorativos, anillo, disco central con icono y
/// sombra de color, pastilla de progreso "PASO n DE 3" e insignias flotantes.
class _OnboardingArtwork extends StatelessWidget {
  final int step;
  final IconData icon;
  final Color accent;
  final bool dark;

  const _OnboardingArtwork({
    required this.step,
    required this.icon,
    required this.accent,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final discBg = dark ? AppColors.surfaceVariantDark : AppColors.white;
    return Container(
      width: double.infinity,
      height: 292,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [accent.withValues(alpha: .30), AppColors.blue900]
              : [accent.withValues(alpha: .18), AppColors.blue50],
        ),
        borderRadius: BorderRadius.circular(AppMetrics.radiusXl),
        border: dark ? Border.all(color: AppColors.borderDark) : null,
        boxShadow: dark ? AppMetrics.shadowCardDark : AppMetrics.shadowCard,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -38,
            child: _GlowCircle(size: 130, color: accent, dark: dark),
          ),
          Positioned(
            left: -30,
            bottom: -34,
            child: _GlowCircle(size: 96, color: accent, dark: dark),
          ),
          Positioned(
            left: 22,
            top: 30,
            child: _GlowCircle(size: 26, color: accent, dark: dark),
          ),
          Center(
            child: Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: dark ? .55 : .35),
                  width: 2,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: discBg,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .35),
                    blurRadius: 34,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 66,
                color: dark ? AppColors.primaryOnDark : accent,
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: dark
                    ? AppColors.primaryOnDarkContainer
                    : AppColors.white.withValues(alpha: .85),
                borderRadius: BorderRadius.circular(AppMetrics.radiusChip),
              ),
              child: Text(
                'PASO ${step + 1} DE 3',
                style: AppTypography.badge.copyWith(
                  fontSize: 9.5,
                  letterSpacing: 1.2,
                  color:
                      dark ? AppColors.primaryOnDark : AppColors.primaryDarker,
                ),
              ),
            ),
          ),
          if (step == 0) ...[
            const Positioned(
                right: 26,
                top: 40,
                child: _MiniBadge(
                    icon: Icons.map_rounded, color: AppColors.secondary)),
            const Positioned(
                left: 30,
                bottom: 44,
                child: _MiniBadge(
                    icon: Icons.school_rounded, color: AppColors.primary)),
          ],
          if (step == 1) ...[
            const Positioned(
                right: 30,
                top: 34,
                child: _MiniBadge(
                    icon: Icons.psychology_rounded,
                    color: AppColors.secondary)),
            const Positioned(
                left: 26,
                bottom: 40,
                child: _MiniBadge(
                    icon: Icons.construction_rounded,
                    color: AppColors.secondary)),
          ],
          if (step == 2) ...[
            const Positioned(
                right: 26,
                top: 34,
                child: _MiniBadge(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.primary)),
            const Positioned(
                left: 28,
                bottom: 46,
                child: _MiniBadge(
                    icon: Icons.rocket_launch_rounded,
                    color: AppColors.secondary)),
          ],
        ],
      ),
    );
  }
}

/// Círculo decorativo translúcido con borde fino (elementos de composición).
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final bool dark;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: dark ? .22 : .14),
          border: Border.all(
            color: color.withValues(alpha: dark ? .30 : .22),
            width: 1.5,
          ),
        ),
      );
}
