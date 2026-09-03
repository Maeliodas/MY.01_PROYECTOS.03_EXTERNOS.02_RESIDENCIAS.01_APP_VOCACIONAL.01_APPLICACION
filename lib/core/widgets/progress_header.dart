import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PROGRESO VOCACIONAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppColors.textGrey,
              ),
            ),
            Text(
              'ETAPA $currentStep DE $totalSteps',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.primaryGreenLight.withValues(alpha: 0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }
}
