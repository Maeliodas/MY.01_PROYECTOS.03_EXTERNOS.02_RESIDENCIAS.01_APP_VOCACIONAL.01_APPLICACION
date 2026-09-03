import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const AppSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.thumb_down_alt_outlined,
                color: AppColors.textGrey, size: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value.toInt().toString(),
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.primaryGreen),
              ),
            ),
            const Icon(Icons.thumb_up_alt_outlined,
                color: AppColors.textGrey, size: 24),
          ],
        ),
        const SizedBox(height: 15),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: AppColors.primaryGreen,
            inactiveTrackColor: AppColors.dividerColor,
            thumbColor: AppColors.primaryGreen,
            overlayColor: AppColors.primaryGreen.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 9.0,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NADA',
                  style: AppTextStyles.badgeText
                      .copyWith(color: AppColors.textGrey)),
              Text('MUCHO',
                  style: AppTextStyles.badgeText
                      .copyWith(color: AppColors.textGrey)),
            ],
          ),
        ),
      ],
    );
  }
}
