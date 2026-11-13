import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/institutional_components.dart';
import '../../../../core/widgets/institutional_logos.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/test_provider.dart';
import '../../../../core/constants/app_constants.dart';

class TestIntroPage extends ConsumerWidget {
  const TestIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accentColor = dark ? AppColors.primaryOnDark : AppColors.primary;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InstitutionalCard(
                padding: EdgeInsets.zero,
                radius: AppMetrics.radiusMd,
                color: dark ? AppColors.surfaceVariantDark : AppColors.blue50,
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Icon(
                    Icons.quiz_outlined,
                    size: 80,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: AppMetrics.xxl),
              Text(
                'Tu viaje aún no comienza.',
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  fontSize: 22,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: AppMetrics.md),
              Text(
                'Descubre tu potencial e intereses con el Test Vocacional oficial.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  fontSize: 15,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: AppMetrics.xxl + AppMetrics.sm),
              PrimaryButton(
                text: '¡Iniciar Test!',
                icon: Icons.play_arrow_rounded,
                onPressed: () async {
                  await ref.read(testProvider.notifier).startNewTestSession();
                  if (context.mounted) context.go('/test');
                },
              ),
              const SizedBox(height: 48),
              const InstitutionalFooter(showNames: false, scale: .9),
            ],
          ),
        ),
      ),
    );
  }
}
