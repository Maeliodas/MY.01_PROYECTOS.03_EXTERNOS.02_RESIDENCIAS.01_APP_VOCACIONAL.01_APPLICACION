import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';

/// Botón de regreso único para toda la aplicación.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark
        ? AppColors.surfaceVariantDark
        : AppColors.blue50;
    final foreground = dark ? AppColors.primaryOnDark : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => context.pop(),
          child: SizedBox(
            width: AppMetrics.touchTarget - 4,
            height: AppMetrics.touchTarget - 4,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
