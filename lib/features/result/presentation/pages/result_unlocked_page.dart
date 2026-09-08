import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/result_provider.dart';

class ResultUnlockedPage extends ConsumerWidget {
  const ResultUnlockedPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestResultProvider);
    return Scaffold(
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => const Center(child: Text('No fue posible cargar el resultado.')),
          data: (result) {
            if (result == null) return _Empty(onStart: () => context.push('/test'));
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              children: [
                const Text('Aevum Iter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF287400))),
                const SizedBox(height: 28),
                Center(child: Container(width: 108, height: 108, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.star_rounded, color: Colors.white, size: 58))),
                const SizedBox(height: 20),
                const Text('¡Resultado\ndesbloqueado!', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, height: .98, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text('Basado en tu perfil cognitivo y pasiones, encontramos una opción con alta afinidad.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68))),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 22, offset: const Offset(0, 10))]),
                  child: Column(children: [
                    Container(width: 96, height: 96, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF7532D2), width: 8)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${result.topCareer.affinityPercentage.round()}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF7532D2))), const Text('MATCH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF7532D2)))])),
                    const SizedBox(height: 16),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF0E3FF), borderRadius: BorderRadius.circular(12)), child: const Text('✦ RECOMENDACIÓN PRINCIPAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6A23C1)))),
                    const SizedBox(height: 12),
                    Text(result.topCareer.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, height: 1.15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 7, runSpacing: 7, alignment: WrapAlignment.center, children: [
                      const _Tag('Resolución de problemas'), const _Tag('Pensamiento analítico'), _Tag('Perfil ${result.riasec.hollandCode}'),
                    ]),
                  ]),
                ),
                const SizedBox(height: 20),
                PrimaryButton(text: 'Ver detalles', icon: Icons.arrow_forward_rounded, onPressed: () => context.push('/result-detail')),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: () => context.push('/career-ranking'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), child: const Text('Explorar otras opciones', style: TextStyle(fontWeight: FontWeight.w800))),
              ],
            );
          },
        ),
      ),
    );
  }
}
class _Tag extends StatelessWidget { final String t; const _Tag(this.t); @override Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: dark ? const Color(0xFF263320) : const Color(0xFFF1F8E8), borderRadius: BorderRadius.circular(10)), child: Text(t, style: TextStyle(fontSize: 11, color: dark ? const Color(0xFFCEE4BC) : const Color(0xFF3B5A27)))); } }
class _Empty extends StatelessWidget { final VoidCallback onStart; const _Empty({required this.onStart}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 110, height: 110, decoration: const BoxDecoration(color: Color(0xFFEAF8D9), shape: BoxShape.circle), child: const Icon(Icons.route_rounded, size: 58, color: AppColors.primary)), const SizedBox(height: 22), const Text('Tu viaje aún no comienza.', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text('Completa el test para desbloquear tus resultados.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68))), const SizedBox(height: 26), PrimaryButton(text: 'Iniciar Test', icon: Icons.play_arrow_rounded, onPressed: onStart)]))); }
