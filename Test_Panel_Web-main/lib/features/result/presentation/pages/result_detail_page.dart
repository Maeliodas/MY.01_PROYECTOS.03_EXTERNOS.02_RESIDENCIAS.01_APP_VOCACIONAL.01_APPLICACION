import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/result_provider.dart';

class ResultDetailPage extends ConsumerWidget {
  const ResultDetailPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestResultProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aevum Iter')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('No fue posible cargar el detalle.')),
        data: (data) {
          if(data == null) return const Center(child: Text('Sin resultado disponible.'));
          return ListView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 30), children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFF0E3FF), borderRadius: BorderRadius.circular(12)), child: Text('RECOMENDACIÓN ${data.riasec.hollandCode}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6C2BC8)))),
            const SizedBox(height: 14),
            Text('Tu futuro en\n${data.topCareer.name}\nempieza hoy.', style: const TextStyle(fontSize: 31, height: 1.03, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text('Con una afinidad de ${data.topCareer.affinityPercentage.round()}%, esta opción se alinea de forma importante con tu perfil vocacional.', style: TextStyle(fontSize: 15, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68))),
            const SizedBox(height: 22),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C2C18) : const Color(0xFFE9FADB), borderRadius: BorderRadius.circular(26)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.analytics_rounded, color: Color(0xFF287400)), SizedBox(width: 9), Text('Desglose RIASEC', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))]), const SizedBox(height: 18), _Bar('Realista (R)', data.riasec.scoreR), _Bar('Investigador (I)', data.riasec.scoreI), _Bar('Artístico (A)', data.riasec.scoreA), _Bar('Social (S)', data.riasec.scoreS), _Bar('Emprendedor (E)', data.riasec.scoreE), _Bar('Convencional (C)', data.riasec.scoreC)])),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF162831) : const Color(0xFFE1F4FF), borderRadius: BorderRadius.circular(26)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Siguiente paso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF18A9D3))), const SizedBox(height: 8), Text('Investiga el plan de estudios, las áreas de especialización y las oportunidades profesionales de la carrera.', style: TextStyle(height: 1.4, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .72)))])),
          ]);
        },
      ),
    );
  }
}
class _Bar extends StatelessWidget { final String label; final double score; const _Bar(this.label, this.score); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${((score/50)*100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))]), const SizedBox(height: 6), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (score / 50).clamp(0.0, 1.0).toDouble(), minHeight: 8, backgroundColor: const Color(0xFFD2DEC7), valueColor: const AlwaysStoppedAnimation(AppColors.primary))) ])); }
