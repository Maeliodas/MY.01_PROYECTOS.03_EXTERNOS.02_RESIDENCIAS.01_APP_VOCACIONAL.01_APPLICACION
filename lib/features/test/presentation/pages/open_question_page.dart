import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../result/domain/services/result_calculator.dart';
import '../providers/test_provider.dart';

class OpenQuestionPage extends ConsumerStatefulWidget {
  const OpenQuestionPage({super.key});

  @override
  ConsumerState<OpenQuestionPage> createState() => _OpenQuestionPageState();
}

class _OpenQuestionPageState extends ConsumerState<OpenQuestionPage> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;
  static const int _minAnswerLength = 10;
  bool get _hasAnswer => _controller.text.trim().length >= _minAnswerLength;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish(
    CareerCatalog career,
    DepartmentQuestion departmentQuestion,
  ) async {
    if (!_hasAnswer) return;
    setState(() => _saving = true);
    final notifier = ref.read(testProvider.notifier);
    await notifier.saveCareerOpenAnswer(
      career.id,
      departmentQuestion.questionText,
      _controller.text.trim(),
    );
    await notifier.completeTest('Pregunta abierta por departamento respondida');
    if (mounted) context.go('/thank-you');
  }

  @override
  Widget build(BuildContext context) {
    final careersAsync = ref.watch(careersCatalogProvider);
    final questionsAsync = ref.watch(departmentQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Interés complementario')),
      body: careersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('No fue posible cargar la carrera recomendada.'),
        ),
        data: (careers) => questionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('No fue posible cargar la pregunta complementaria.'),
          ),
          data: (departmentQuestions) {
            final test = ref.watch(testProvider);
            final riasec = ResultCalculator.calculate(
              test.answers,
              test.questions,
            );
            final ranking = ResultCalculator.calculateCareerMatches(
              riasec,
              careers,
              answers: test.answers,
            );

            if (ranking.isEmpty) {
              return const Center(
                child: Text('No hay carreras activas para generar el resultado.'),
              );
            }

            final topId = ranking.first.careerId;
            final topCareer = careers.firstWhere(
              (career) => career.id == topId,
            );

            final departmentQuestion = departmentQuestions
                .where((item) => item.department == topCareer.department)
                .firstOrNull;

            if (departmentQuestion == null ||
                departmentQuestion.questionText.trim().isEmpty) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.help_outline_rounded, size: 54),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no hay una pregunta configurada para el departamento ${topCareer.department}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, height: 1.4),
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        text: 'Continuar',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () async {
                          await ref
                              .read(testProvider.notifier)
                              .completeTest('Sin pregunta departamental');
                          if (context.mounted) context.go('/thank-you');
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                children: [
                  const Text(
                    'Una última pregunta',
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Esta última respuesta complementa el test y no modifica tu puntuación RIASEC ni el porcentaje de afinidad.',
                    style: TextStyle(
                      height: 1.45,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pregunta final',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            departmentQuestion.questionText,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _controller,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Escribe lo que te gustaría realizar...',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_hasAnswer ? 'Respuesta lista para guardar.' : 'Esta respuesta es obligatoria para finalizar el test (mínimo $_minAnswerLength caracteres).', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _hasAnswer ? const Color(0xFF00923F) : Theme.of(context).colorScheme.error)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Finalizar test',
                    icon: Icons.check_rounded,
                    isLoading: _saving,
                    onPressed: (_saving || !_hasAnswer)
                        ? null
                        : () => _finish(topCareer, departmentQuestion),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
