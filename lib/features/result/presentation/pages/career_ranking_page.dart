import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/result_provider.dart';

class CareerRankingPage extends ConsumerWidget {
  const CareerRankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestResultProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aevum Iter')),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) =>
            const Center(child: Text('Error al cargar las carreras.')),
        data: (result) {
          if (result == null) {
            return const Center(
              child: Text('Completa el test para ver tus opciones.'),
            );
          }

          final topThree = result.topThree;

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MEJORES OPCIONES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6C2BC8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tus mejores\nopciones',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Basado en tus habilidades, intereses y metas profesionales, '
                'estas son las 3 carreras que mejor se alinean contigo.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .68),
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(topThree.length, (i) {
                final career = topThree[i];
                final top = i == 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: top ? AppColors.primary : const Color(0xFFE5ECD9),
                      width: top ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .045),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (top)
                        const Text(
                          '● COMPATIBILIDAD MÁXIMA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF287400),
                            letterSpacing: .7,
                          ),
                        ),
                      if (top) const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              career.name,
                              style: TextStyle(
                                fontSize: top ? 20 : 17,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${career.affinityPercentage.round()}%',
                            style: TextStyle(
                              fontSize: top ? 24 : 19,
                              fontWeight: FontWeight.w900,
                              color: top
                                  ? AppColors.primaryDark
                                  : const Color(0xFF18A9D3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: career.affinityPercentage / 100,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE4EBDD),
                          valueColor: AlwaysStoppedAnimation(
                            top ? AppColors.primary : const Color(0xFF18A9D3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(
                            '/career-info',
                            extra: {
                              'careerId': career.careerId,
                              'name': career.name,
                              'affinity': career.affinityPercentage,
                              'rank': i + 1,
                            },
                          ),
                          child: const Text(
                            'Ver detalles →',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
