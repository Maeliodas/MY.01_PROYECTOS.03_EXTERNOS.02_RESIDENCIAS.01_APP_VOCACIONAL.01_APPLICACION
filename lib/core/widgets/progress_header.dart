import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class ProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMapPressed;

  const ProgressHeader({
    super.key,
    required this.currentIndex,
    required this.total,
    this.onBackPressed,
    this.onMapPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentIndex + 1) / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryGreen, size: 20),
              onPressed: onBackPressed,
            ),
            Row(
              children: [
                Text('PROGRESO VOCACIONAL ',
                    style: AppTextStyles.badgeText
                        .copyWith(color: AppColors.textGrey)),
                Text('ETAPA ${currentIndex + 1} DE $total',
                    style: AppTextStyles.badgeText
                        .copyWith(color: AppColors.primaryGreen)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined,
                  color: AppColors.primaryGreen, size: 22),
              onPressed: onMapPressed,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.dividerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
