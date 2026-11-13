import 'dart:io';
import '../../../../core/constants/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/institutional_components.dart';
import '../../../../core/widgets/institutional_logos.dart';
import '../../../../core/widgets/institutional_support_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/test_provider.dart';

class TestProgressTreePage extends ConsumerWidget {
  final VoidCallback? onShowResult;

  const TestProgressTreePage({super.key, this.onShowResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final test = ref.watch(testProvider);
    final profile = ref.watch(profileProvider);
    if (!test.restored || test.isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
    }
    final complete = test.isCompleted;
    final answered = test.answers.length;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final totalQuestions = test.questions.length;
    final percentage = complete
        ? 100
        : totalQuestions == 0
            ? 0
            : ((answered / totalQuestions) * 100).round().clamp(0, 100);

    void continueTest() => context.push('/test');
    void showResult() {
      if (onShowResult != null) {
        onShowResult!();
      } else {
        context.go('/path-home?tab=1');
      }
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [AppColors.backgroundDark, AppColors.blue900]
                : const [AppColors.white, AppColors.blue50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 92),
                children: [
                  Row(
                    children: [
                      _Avatar(path: profile?.avatarConfig.avatarPath),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName.toUpperCase(),
                              style: AppTypography.micro.copyWith(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                color: dark
                                    ? AppColors.primaryOnDark
                                    : AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            PageHeader(
                              title: profile == null
                                  ? '¡Hola!'
                                  : '¡Hola, ${profile.name.split(' ').first}!',
                              accentBar: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InstitutionalLogos.mark(height: 52),
                    ],
                  ),
                  const SizedBox(height: 22),
                  InstitutionalCard(
                    padding: const EdgeInsets.all(AppMetrics.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: SectionLabel('Progreso actual'),
                            ),
                            Icon(
                              Icons.rocket_launch_rounded,
                              color: dark
                                  ? AppColors.primaryOnDark
                                  : AppColors.secondary,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complete
                              ? 'Tu viaje profesional\nestá despegando.'
                              : answered == 0
                                  ? 'Tu viaje aún no\ncomienza.'
                                  : 'Tu viaje profesional\nsigue avanzando.',
                          style: AppTypography.display.copyWith(height: 1.05),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 9,
                                  backgroundColor: dark
                                      ? AppColors.borderDark
                                      : AppColors.blue100,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percentage%',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: dark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (answered == 0 && !complete) ...[
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppMetrics.radiusLg),
                        gradient: LinearGradient(
                          colors: dark
                              ? const [
                                  AppColors.blue700,
                                  AppColors.blue800,
                                  AppColors.blue900,
                                ]
                              : const [
                                  AppColors.blue50,
                                  AppColors.blue100,
                                  AppColors.blue200,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: InkResponse(
                          onTap: continueTest,
                          radius: 60,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: dark
                                ? AppColors.surfaceVariantDark
                                : AppColors.white,
                            child: Icon(
                              Icons.map_rounded,
                              size: 48,
                              color: dark
                                  ? AppColors.primaryOnDark
                                  : AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Tu viaje aún no\ncomienza.',
                      textAlign: TextAlign.center,
                      style: AppTypography.display.copyWith(height: 1.05),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Descubre tu potencial hoy mismo.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        fontSize: 17,
                        color: dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      text: 'Iniciar Test',
                      onPressed: continueTest,
                      icon: Icons.play_arrow_rounded,
                    ),
                  ] else ...[
                    _Node(
                      icon: Icons.favorite_rounded,
                      title: 'Intereses',
                      done:
                          answered >= ((totalQuestions / 3).ceil()) || complete,
                      active:
                          !complete && answered < ((totalQuestions / 3).ceil()),
                      onTap: complete ? showResult : continueTest,
                    ),
                    const _Connector(),
                    _Node(
                      icon: Icons.psychology_rounded,
                      title: 'Habilidades',
                      done: answered >= ((totalQuestions * 2 / 3).ceil()) ||
                          complete,
                      active: !complete &&
                          answered >= ((totalQuestions / 3).ceil()) &&
                          answered < ((totalQuestions * 2 / 3).ceil()),
                      onTap: answered >= ((totalQuestions / 3).ceil())
                          ? (complete ? showResult : continueTest)
                          : null,
                    ),
                    const _Connector(),
                    _Node(
                      icon: Icons.person_search_rounded,
                      title: 'Personalidad',
                      done: complete,
                      active: !complete &&
                          answered >= ((totalQuestions * 2 / 3).ceil()),
                      onTap: answered >= ((totalQuestions * 2 / 3).ceil())
                          ? (complete ? showResult : continueTest)
                          : null,
                    ),
                    const _Connector(),
                    _Node(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Resultado',
                      done: complete,
                      active: false,
                      onTap: complete ? showResult : null,
                    ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      text: complete ? 'Ver resultado  →' : 'Continuar Test  →',
                      onPressed: complete ? showResult : continueTest,
                    ),
                    const SizedBox(height: 10),
                    if (complete)
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(testProvider.notifier).resetTest();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reiniciar Test'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppMetrics.radiusXl),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              const Positioned(
                right: 18,
                bottom: 14,
                child: InstitutionalSupportBubble(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? path;

  const _Avatar({this.path});

  @override
  Widget build(BuildContext context) {
    Widget child = const Icon(Icons.person, size: 24);
    if (path != null && path!.isNotEmpty) {
      final local = path!.startsWith('/') || path!.contains('emulated');
      child = local
          ? Image.file(
              File(path!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person),
            )
          : Image.asset(
              path!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person),
            );
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipOval(child: child),
    );
  }
}

class _Node extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool done;
  final bool active;
  final VoidCallback? onTap;

  const _Node({
    required this.icon,
    required this.title,
    required this.done,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final circleColor = done || active
        ? AppColors.primary
        : (dark ? AppColors.surfaceVariantDark : AppColors.blue100);

    return Semantics(
      button: enabled,
      label: enabled ? '$title. Toca para continuar.' : title,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: active ? 82 : 74,
                height: active ? 82 : 74,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: AppColors.onPrimary, width: 5)
                      : null,
                  boxShadow: done || active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .27),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  done ? Icons.check_rounded : icon,
                  color: done || active ? AppColors.onPrimary : secondary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.title.copyWith(
              fontSize: 17,
              color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          Text(
            done
                ? 'COMPLETADO'
                : active
                    ? 'CONTINUAR'
                    : 'PENDIENTE',
            style: AppTypography.micro.copyWith(
              color: done || active
                  ? (dark ? AppColors.primaryOnDark : AppColors.primary)
                  : secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 6,
        height: 48,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: dark ? AppColors.primaryOnDark : AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
