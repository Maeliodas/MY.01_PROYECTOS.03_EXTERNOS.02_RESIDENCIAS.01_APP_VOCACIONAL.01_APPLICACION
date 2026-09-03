import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

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
        // Indicador numérico circular según Figma
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primaryGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${value.round()}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Slider con etiquetas
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NADA',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLightGrey)),
            Text('MUCHO',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLightGrey)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primaryGreen,
            inactiveTrackColor: AppColors.primaryGreenLight.withValues(alpha: 0.3),
            thumbColor: AppColors.primaryGreen,
            overlayColor: AppColors.primaryGreen.withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 9,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
