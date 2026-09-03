import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/result_card.dart';
import '../providers/result_provider.dart';

class ResultUnlockedPage extends ConsumerWidget {
  const ResultUnlockedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(latestResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: resultAsync.when(
        data: (result) {
          if (result == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_late_outlined,
                        size: 64, color: AppColors.textGrey),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no has completado tu test vocacional.',
                      style: TextStyle(fontSize: 16, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Ir al Test',
                      onPressed: () => context.push('/test-intro'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    '¡Resultado desbloqueado!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Basado en tu perfil Holland (${result.riasec.hollandCode})',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 24),
                  ResultCard(
                    careerName: result.topCareer.name,
                    affinityPercentage: result.topCareer.affinityPercentage,
                    demandTag: result.topCareer.demandTag,
                    onTap: () => context.push('/result-detail'),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: 'Ver ranking completo',
                    onPressed: () => context.push('/career-ranking'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (_, __) =>
            const Center(child: Text('Error al cargar resultados')),
      ),
    );
  }
}
