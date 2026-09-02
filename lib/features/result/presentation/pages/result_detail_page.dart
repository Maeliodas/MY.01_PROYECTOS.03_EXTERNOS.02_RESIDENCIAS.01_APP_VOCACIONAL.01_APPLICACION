import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/riasec_constants.dart';
import '../../../../core/widgets/result_card.dart';
import '../providers/result_provider.dart';

class ResultDetailPage extends ConsumerWidget {
  const ResultDetailPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final x = r.watch(latestResultProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis resultados')),
      body: x.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) {
          if (d == null) return const Center(child: Text('No hay resultados'));
          final ri = riasecFromJson(
                (d['riasec'] as Map).cast<String, dynamic>(),
              ),
              cs = careersFromJson(d['careers'] as List);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Código Holland: ${d['hollandCode']}',
                style: Theme.of(c).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Text('Perfil RIASEC', style: Theme.of(c).textTheme.titleLarge),
              ...RiasecType.values.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${t.name} (${t.code})'),
                      LinearProgressIndicator(value: ri.percentage(t) / 100),
                      Text('${ri.scores[t]}/45'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tus principales coincidencias',
                style: Theme.of(c).textTheme.titleLarge,
              ),
              ...cs
                  .take(3)
                  .toList()
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ResultCard(
                        position: e.key + 1,
                        title: e.value.careerName,
                        score: e.value.score,
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => c.push('/result/careers'),
                child: const Text('Ver ranking completo'),
              ),
            ],
          );
        },
      ),
    );
  }
}
