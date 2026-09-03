import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/test_provider.dart';

class TestIntroPage extends ConsumerWidget {
  const TestIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aevum Iter')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryGreenLight.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.quiz_outlined,
                    size: 80, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tu viaje aún no comienza.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Descubre tu potencial e intereses con el Test Vocacional oficial.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 15),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: '¡Iniciar Test!',
                onPressed: () async {
                  await ref.read(testProvider.notifier).startNewTestSession();
                  if (context.mounted) {
                    context.go('/test');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
