import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/result_card.dart';
import '../providers/result_provider.dart';

class CareerRankingPage extends ConsumerWidget {
  const CareerRankingPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final x = r.watch(latestResultProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking de carreras')),
      body: x.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) {
          if (d == null) return const Center(child: Text('No hay resultados'));
          final cs = careersFromJson(d['careers'] as List);
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: cs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => ResultCard(
              position: i + 1,
              title: cs[i].careerName,
              score: cs[i].score,
            ),
          );
        },
      ),
    );
  }
}
