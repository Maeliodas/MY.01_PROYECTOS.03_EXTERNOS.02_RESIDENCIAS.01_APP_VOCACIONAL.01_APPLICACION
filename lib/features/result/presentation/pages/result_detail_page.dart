import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/result_provider.dart';

class ResultDetailPage extends ConsumerWidget {
  const ResultDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(latestResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Vocacional')),
      body: resultAsync.when(
        data: (data) {
          if (data == null) return const SizedBox();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.topCareer.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Afinidad Total: ${data.topCareer.affinityPercentage.round()}%',
                  style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Desglose RIASEC',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _RiasecBar(label: 'Realista (R)', value: data.riasec.scoreR),
                _RiasecBar(
                    label: 'Investigador (I)', value: data.riasec.scoreI),
                _RiasecBar(label: 'Artístico (A)', value: data.riasec.scoreA),
                _RiasecBar(label: 'Social (S)', value: data.riasec.scoreS),
                _RiasecBar(label: 'Emprendedor (E)', value: data.riasec.scoreE),
                _RiasecBar(
                    label: 'Convencional (C)', value: data.riasec.scoreC),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}

class _RiasecBar extends StatelessWidget {
  final String label;
  final double value;

  const _RiasecBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (value / 45.0).clamp(0.0, 1.0),
            minHeight: 8,
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.primaryGreenLight.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
