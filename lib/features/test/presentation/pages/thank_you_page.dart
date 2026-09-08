import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../result/data/result_local_datasource.dart';
import '../../../result/domain/services/result_calculator.dart';
import '../../../result/presentation/providers/result_provider.dart';
import '../providers/test_provider.dart';

class ThankYouPage extends ConsumerStatefulWidget {
  const ThankYouPage({super.key});
  @override ConsumerState<ThankYouPage> createState() => _ThankYouPageState();
}
class _ThankYouPageState extends ConsumerState<ThankYouPage> {
  bool saving = true;
  @override void initState(){ super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _save()); }
  Future<void> _save() async {
    final answers = ref.read(testProvider).answers;
    if (answers.length >= 30) {
      final riasec = ResultCalculator.calculate(answers);
      final ranking = ResultCalculator.calculateCareerMatches(riasec, answers: answers);
      if (ranking.isNotEmpty) {
        await ref.read(resultDatasourceProvider).saveResult(
          sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
          scoreR: riasec.scoreR, scoreI: riasec.scoreI, scoreA: riasec.scoreA, scoreS: riasec.scoreS, scoreE: riasec.scoreE, scoreC: riasec.scoreC,
          hollandCode: riasec.hollandCode,
          topCareerId: ranking.first.careerId, topCareerName: ranking.first.name, topCareerAffinity: ranking.first.affinityPercentage,
          fullRanking: ranking.map((c) => {'career_id': c.careerId, 'name': c.name, 'affinity': c.affinityPercentage}).toList(),
        );
        ref.invalidate(latestResultProvider);
        ref.invalidate(resultHistoryProvider);
      }
    }
    if(mounted) setState(() => saving = false);
  }
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 104, height: 104, decoration: const BoxDecoration(color: Color(0xFFEAF8D9), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.primary)),
      const SizedBox(height: 26),
      const Text('¡Gracias por responder!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Text('Tus datos han sido procesados. Ya puedes descubrir tu vocación y las carreras más afines.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68))),
      const SizedBox(height: 40),
      PrimaryButton(text: saving ? 'Procesando...' : 'Ver mis resultados', icon: saving ? null : Icons.arrow_forward_rounded, isLoading: saving, onPressed: saving ? null : () => context.go('/result-analysis')),
    ]))),
  );
}
