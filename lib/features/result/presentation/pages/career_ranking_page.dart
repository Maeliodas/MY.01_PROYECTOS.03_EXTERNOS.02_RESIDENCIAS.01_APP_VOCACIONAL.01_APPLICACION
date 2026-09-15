import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_notice_dialog.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/result_provider.dart';

class CareerRankingPage extends ConsumerWidget {
  const CareerRankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestResultProvider);
    final catalogs = ref.watch(careersCatalogProvider).valueOrNull ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('App Vocacional ITTUX')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error al cargar las carreras.')),
        data: (result) {
          if (result == null) {
            return const Center(child: Text('Completa el test para ver tus opciones.'));
          }
          final topThree = result.topThree;
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF0E3FF), borderRadius: BorderRadius.circular(12)),
                child: const Text('TOP 3 VOCACIONAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6C2BC8))),
              ),
              const SizedBox(height: 12),
              const Text('Tus 3 mejores\nopciones', style: TextStyle(fontSize: 34, height: 1.0, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(
                'Estas son las tres carreras con mayor afinidad respecto a tu perfil RIASEC. Puedes revisar el detalle de cada una.',
                style: TextStyle(fontSize: 15, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68)),
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
                    border: Border.all(color: top ? AppColors.primary : const Color(0xFFE5ECD9), width: top ? 2 : 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .045), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i == 0 ? '1.er lugar' : '${i + 1}.º lugar',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: top ? const Color(0xFF00923F) : const Color(0xFF66746A)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(career.name, style: TextStyle(fontSize: top ? 20 : 18, height: 1.15, fontWeight: FontWeight.w900))),
                          const SizedBox(width: 12),
                          Text('${career.affinityPercentage.round()}%', style: TextStyle(fontSize: top ? 24 : 20, fontWeight: FontWeight.w900, color: top ? AppColors.primaryDark : const Color(0xFF18A9D3))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: career.affinityPercentage / 100,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE4EBDD),
                          valueColor: AlwaysStoppedAnimation(top ? AppColors.primary : const Color(0xFF18A9D3)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final matches = catalogs.where((c) => c.id == career.careerId).toList();
                            final url = matches.isEmpty ? '' : matches.first.websiteUrl.trim();
                            if (url.isEmpty) {
                              if (context.mounted) {
                                await showAppNoticeDialog(
                                  context,
                                  icon: Icons.language_rounded,
                                  title: 'Página no disponible',
                                  content: const Text(
                                    'La página oficial de esta carrera todavía no está disponible. Puedes volver a consultarla más adelante desde App Vocacional ITTUX.',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return;
                            }
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          },
                          child: const Text('Ver detalles en TecNM →', style: TextStyle(fontWeight: FontWeight.w800)),
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
