import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/test_provider.dart';

class OpenQuestionPage extends ConsumerStatefulWidget {
  const OpenQuestionPage({super.key});

  @override
  ConsumerState<OpenQuestionPage> createState() => _OpenQuestionPageState();
}

class _OpenQuestionPageState extends ConsumerState<OpenQuestionPage> {
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflexión Final')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Tomaste el test en serio y respondiste honestamente?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cuéntanos brevemente tus expectativas sobre tu carrera ideal.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _answerController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Escribe tu respuesta aquí...',
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Finalizar Test',
                onPressed: () async {
                  await ref
                      .read(testProvider.notifier)
                      .completeTest(_answerController.text.trim());
                  if (context.mounted) {
                    context.go('/thank-you');
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
