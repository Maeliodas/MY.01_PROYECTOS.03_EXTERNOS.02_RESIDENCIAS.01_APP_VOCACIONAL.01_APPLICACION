import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../app/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({super.key, required this.message, this.icon = Icons.inbox});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: dark ? AppColors.surfaceVariantDark : AppColors.blue50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: dark ? AppColors.primaryOnDark : AppColors.blue400,
              ),
            ),
            const SizedBox(height: AppMetrics.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
