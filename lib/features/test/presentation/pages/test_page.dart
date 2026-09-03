import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_slider.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/progress_header.dart';
import '../../data/questions_data.dart';
import '../providers/test_provider.dart';

class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  double _sliderValue = 5.0;

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testProvider);
    if (testState.session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questionId = testState.session!.questionOrder[testState.currentIndex];
    final question =
        QuestionsData.questions.firstWhere((q) => q.id == questionId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aevum Iter'),
        actions: [
          // Botón obligatorio para guardar progreso
          IconButton(
            icon:
                const Icon(Icons.save_outlined, color: AppColors.primaryGreen),
            onPressed: () {
              context.go('/path-home');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ProgressHeader(
                currentStep: testState.currentIndex + 1,
                totalSteps: 30,
              ),
              const Spacer(),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        question.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      AppSlider(
                        value: _sliderValue,
                        onChanged: (val) => setState(() => _sliderValue = val),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Continuar',
                onPressed: () async {
                  final notifier = ref.read(testProvider.notifier);
                  await notifier.answerQuestion(
                      question.id, _sliderValue.round());

                  if (testState.currentIndex < 29) {
                    notifier.nextQuestion();
                    setState(() => _sliderValue = 5.0);
                  } else {
                    // Verificación de montaje antes de usar BuildContext
                    if (context.mounted) {
                      context.go('/open-question');
                    }
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
