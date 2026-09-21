import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../result/data/result_local_datasource.dart';
import '../../../result/domain/services/result_calculator.dart';
import '../../../result/presentation/providers/result_provider.dart';
import '../../data/test_local_datasource.dart';
import '../providers/test_provider.dart';

class ThankYouPage extends ConsumerStatefulWidget {
  const ThankYouPage({super.key});

  @override
  ConsumerState<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends ConsumerState<ThankYouPage> {
  bool saving = true;
  String status = 'Calculando tu resultado…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  void _setStatus(String value) {
    if (mounted) setState(() => status = value);
  }

  Future<void> _save() async {
    final test = ref.read(testProvider);
    // Test incompleto: no hay resultado que mostrar, se regresa al test.
    if (test.questions.isEmpty || test.answers.length < test.questions.length) {
      if (mounted) context.go('/test');
      return;
    }
    try {
      final careers = await ref.read(careersCatalogProvider.future);
      _setStatus('Calculando tu resultado…');
      final riasec = ResultCalculator.calculate(test.answers, test.questions);
      final ranking = ResultCalculator.calculateCareerMatches(
        riasec,
        careers,
        answers: test.answers,
      );
      if (ranking.isEmpty) {
        if (mounted) setState(() => saving = false);
        return;
      }
      final sessionId = test.sessionId ??
          DateTime.now().millisecondsSinceEpoch.toString();
      // La pregunta abierta es obligatoria: si existe pregunta para el
      // departamento del top 1 y aún no hay respuesta, se regresa a ella.
      // Se fija el top calculado aquí para que coincida con lo guardado.
      final topCareer = ranking.first;
      String topDepartment = '';
      for (final c in careers) {
        if (c.id == topCareer.careerId) {
          topDepartment = c.department;
          break;
        }
      }
      final needsOpen = topDepartment.isNotEmpty &&
          (await ref.read(departmentQuestionsProvider.future))
              .any((q) => q.department == topDepartment);
      if (needsOpen) {
        final openAnswers =
            await TestLocalDatasource().getCareerOpenAnswers(sessionId);
        final hasTopAnswer = openAnswers.any(
          (a) =>
              (a['career_id'] ?? '') == topCareer.careerId &&
              (a['answer'] ?? '').trim().length >= 10,
        );
        if (!hasTopAnswer) {
          if (mounted) context.go('/open-question');
          return;
        }
      }
      _setStatus('Guardando tu resultado…');
      final resultId = await ref.read(resultDatasourceProvider).saveResult(
            sessionId: sessionId,
            scoreR: riasec.scoreR,
            scoreI: riasec.scoreI,
            scoreA: riasec.scoreA,
            scoreS: riasec.scoreS,
            scoreE: riasec.scoreE,
            scoreC: riasec.scoreC,
            hollandCode: riasec.hollandCode,
            topCareerId: topCareer.careerId,
            topCareerName: topCareer.name,
            topCareerAffinity: topCareer.affinityPercentage,
            fullRanking: ranking
                .map((c) => {
                      'career_id': c.careerId,
                      'name': c.name,
                      'affinity': c.affinityPercentage,
                    })
                .toList(),
          );

      final profile = ref.read(profileProvider);
      if (profile != null) {
        _setStatus('Enviando tu resultado…');
        await SyncService().processStudentResult(
          resultId: resultId,
          sessionId: sessionId,
          profile: profile,
          riasec: riasec,
          topCareer: topCareer,
        );
      }
      ref.invalidate(latestResultProvider);
      ref.invalidate(resultHistoryProvider);
    } catch (_) {
      // Se conserva el resultado local ya guardado (si existe) y se muestra
      // la pantalla para continuar; la cola reintentará el envío.
    }
    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF8D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  '¡Gracias por responder!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tus datos han sido procesados. Ya puedes descubrir tu vocación y las carreras más afines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .68),
                  ),
                ),
                const SizedBox(height: 40),
                if (saving)
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .6),
                    ),
                  ),
                if (saving) const SizedBox(height: 12),
                PrimaryButton(
                  text: saving ? 'Procesando...' : 'Ver mis resultados',
                  icon: saving ? null : Icons.arrow_forward_rounded,
                  isLoading: saving,
                  onPressed:
                      saving ? null : () => context.go('/result-analysis'),
                ),
              ],
            ),
          ),
        ),
      );
}
