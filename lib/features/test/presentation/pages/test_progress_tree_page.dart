import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/test_provider.dart';

class TestProgressTreePage extends ConsumerWidget {
  const TestProgressTreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);
    final isFinished = testState.isCompleted;

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Vocacional')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Tu viaje profesional está despegando.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Árbol de nodos
              Expanded(
                child: ListView(
                  children: const [
                    _TreeNode(title: 'Intereses', isCompleted: true),
                    _TreeNode(title: 'Habilidades', isCompleted: true),
                    _TreeNode(title: 'Personalidad', isCompleted: true),
                    _TreeNode(
                        title: 'Resultado', isCompleted: true, isLast: true),
                  ],
                ),
              ),

              PrimaryButton(
                text: isFinished ? 'Reiniciar Test' : 'Continuar Test',
                onPressed: () async {
                  if (isFinished) {
                    await ref.read(testProvider.notifier).startNewTestSession();
                  }
                  if (context.mounted) {
                    context.push('/test');
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

class _TreeNode extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isLast;

  const _TreeNode({
    required this.title,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isCompleted
                  ? AppColors.primaryGreen
                  : AppColors.textLightGrey,
              child: Icon(
                isCompleted ? Icons.check : Icons.lock,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 30,
            color:
                isCompleted ? AppColors.primaryGreen : AppColors.textLightGrey,
          ),
      ],
    );
  }
}
