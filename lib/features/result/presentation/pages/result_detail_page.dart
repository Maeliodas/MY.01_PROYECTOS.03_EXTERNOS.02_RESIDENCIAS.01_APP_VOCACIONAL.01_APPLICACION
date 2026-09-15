import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/result_provider.dart';

class ResultDetailPage extends ConsumerWidget {
  final String? careerId;
  const ResultDetailPage({super.key, this.careerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(latestResultProvider);
    final careersAsync = ref.watch(careersCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de carrera')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('No fue posible cargar el detalle.')),
        data: (data) {
          if (data == null) return const Center(child: Text('Sin resultado disponible.'));
          final match = data.ranking.firstWhere(
            (item) => item.careerId == careerId,
            orElse: () => data.topCareer,
          );
          final catalog = careersAsync.valueOrNull;
          final details = catalog?.where((item) => item.id == match.careerId).toList() ?? const [];
          final description = details.isNotEmpty
              ? details.first.description
              : 'Consulta el plan de estudios, las áreas de especialización y el campo laboral de esta carrera.';
          final holland = details.isNotEmpty ? details.first.hollandCode : data.riasec.hollandCode;

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF0E3FF), borderRadius: BorderRadius.circular(12)),
                child: Text('PERFIL $holland', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6C2BC8))),
              ),
              const SizedBox(height: 14),
              Text(match.name, style: const TextStyle(fontSize: 31, height: 1.03, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('Afinidad ${match.affinityPercentage.round()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
              const SizedBox(height: 12),
              Text(description, style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .72))),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C2C18) : const Color(0xFFE9FADB),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.analytics_rounded, color: Color(0xFF00923F)), SizedBox(width: 9), Text('Tu perfil RIASEC', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))]),
                    const SizedBox(height: 18),
                    _Bar('Realista (R)', data.riasec.scoreR),
                    _Bar('Investigador (I)', data.riasec.scoreI),
                    _Bar('Artístico (A)', data.riasec.scoreA),
                    _Bar('Social (S)', data.riasec.scoreS),
                    _Bar('Emprendedor (E)', data.riasec.scoreE),
                    _Bar('Convencional (C)', data.riasec.scoreC),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double score;
  const _Bar(this.label, this.score);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${((score / 50) * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (score / 50).clamp(0.0, 1.0).toDouble(),
                minHeight: 8,
                backgroundColor: const Color(0xFFD2DEC7),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      );
}
