import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/test_provider.dart';

class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});
  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  double value = 5;

  Future<bool> _confirmExit() async {
    final state = ref.read(testProvider);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 68, height: 68, decoration: const BoxDecoration(color: Color(0xFFEAD8FF), shape: BoxShape.circle), child: const Icon(Icons.pause_rounded, color: Color(0xFF6F24CB), size: 34)),
              const SizedBox(height: 18),
              const Text('¿Deseas salir?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text('Tu progreso se guardará automáticamente.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.35, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68))),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFF1F9E8), borderRadius: BorderRadius.circular(22)),
                child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ESTADO ACTUAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: 1)), SizedBox(height: 3)])), Text('Pregunta ${state.currentIndex + 1} de ${state.questions.length}', style: const TextStyle(fontWeight: FontWeight.w700))]),
              ),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: () => Navigator.pop(dialogContext, false), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: const Color(0xFF1B350C), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), child: const Text('×  Cancelar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 52, child: FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), child: const Text('▣  Guardar y Salir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testProvider);
    if (state.isLoading || !state.restored) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null || state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aevum Iter')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.error ?? 'No hay preguntas disponibles en la base de datos.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final q = state.questions[state.currentIndex];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) context.pop();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [Color(0xFF0F160D), Color(0xFF121A10), Color(0xFF102019)]
                  : const [Color(0xFFF7FFE9), Color(0xFFF4F8E9), Color(0xFFE7FFF8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              child: Column(
                children: [
                  Row(children: [IconButton(onPressed: () async { if (await _confirmExit() && context.mounted) context.pop(); }, icon: const Icon(Icons.arrow_back_rounded)), const Text('Aevum Iter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF287400)))]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('PROGRESO VOCACIONAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: .8)), Text('ETAPA ${state.currentIndex + 1} DE ${state.questions.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: .6))]),
                  const SizedBox(height: 9),
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: LinearProgressIndicator(value: state.progress, minHeight: 10, backgroundColor: const Color(0xFFE1E8D9), valueColor: const AlwaysStoppedAnimation(Color(0xFF18A9D3)))),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 38, 24, 32),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: .96), borderRadius: BorderRadius.circular(34), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 22, offset: const Offset(0, 10))]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(q.text, textAlign: TextAlign.center, style: TextStyle(fontSize: 25, height: 1.18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
                            const SizedBox(height: 34),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [const _ScaleIcon(icon: Icons.block_rounded, label: 'NADA', active: false), const SizedBox(width: 28), Container(width: 78, height: 78, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFEAF8D9), shape: BoxShape.circle), child: Text(value.round().toString(), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF287400)))), const SizedBox(width: 28), const _ScaleIcon(icon: Icons.input_rounded, label: 'MUCHO', active: true)]),
                            const SizedBox(height: 22),
                            SliderTheme(data: SliderTheme.of(context).copyWith(trackHeight: 8, activeTrackColor: AppColors.primary, inactiveTrackColor: const Color(0xFFDDE5D4), thumbColor: AppColors.primary, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15), overlayShape: const RoundSliderOverlayShape(overlayRadius: 24)), child: Slider(value: value, min: 0, max: 10, divisions: 10, onChanged: (v) => setState(() => value = v))),
                            const SizedBox(height: 26),
                            SizedBox(width: double.infinity, height: 58, child: ElevatedButton(onPressed: () async {
                              await ref.read(testProvider.notifier).answerQuestion(value);
                              final done = await ref.read(testProvider.notifier).nextQuestion();
                              if (!context.mounted) return;
                              if (done) {
                                context.go('/open-question');
                              } else {
                                final nextState = ref.read(testProvider);
                                final nextId = nextState.questions[nextState.currentIndex].id;
                                setState(() => value = nextState.answers[nextId] ?? 5);
                              }
                            }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: const Color(0xFF18320B), elevation: 3, shadowColor: const Color(0xFF4F8E13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text('Continuar  ›', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _ScaleIcon({required this.icon, required this.label, required this.active});
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: .58); return Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: active ? (dark ? const Color(0xFF263A1D) : const Color(0xFFEAF8D9)) : (dark ? const Color(0xFF283025) : const Color(0xFFF1F3ED)), shape: BoxShape.circle), child: Icon(icon, color: active ? AppColors.primary : secondary)), const SizedBox(height: 7), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? AppColors.primary : secondary))]); }
}
