import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../app/theme/app_typography.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.primaryOnDark : AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: AppMetrics.buttonHeight,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: foreground, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.radiusButton),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: AppTypography.button.copyWith(
            letterSpacing: .8,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
