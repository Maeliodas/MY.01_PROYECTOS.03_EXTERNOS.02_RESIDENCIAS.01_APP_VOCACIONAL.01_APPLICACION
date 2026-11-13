import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/test_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/institutional_components.dart';

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
      builder: (dialogContext) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final titleColor =
            dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final secondaryColor =
            dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
        final accentColor = dark ? AppColors.primaryOnDark : AppColors.primary;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppMetrics.radiusLg)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: dark
                        ? AppColors.primaryOnDarkContainer
                        : AppColors.secondaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pause_rounded, color: accentColor, size: 34),
                ),
                const SizedBox(height: 18),
                Text('¿Deseas salir?',
                    style: AppTypography.display.copyWith(color: titleColor)),
                const SizedBox(height: 7),
                Text(
                  'Tu progreso se guardará automáticamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, height: 1.35, color: secondaryColor),
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: dark
                        ? AppColors.surfaceVariantDark
                        : AppColors.blue50,
                    borderRadius:
                        BorderRadius.circular(AppMetrics.radiusLg),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ESTADO ACTUAL',
                              style: AppTypography.sectionLabel
                                  .copyWith(color: accentColor)),
                          const SizedBox(height: 3),
                        ],
                      ),
                    ),
                    Text(
                        'Pregunta ${state.currentIndex + 1} de ${state.questions.length}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: titleColor)),
                  ]),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: AppMetrics.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppMetrics.radiusButton)),
                    ),
                    child: const Text('×  Cancelar',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: AppMetrics.buttonHeight,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppMetrics.radiusButton))),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 9),
                          Text('Guardar y Salir',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        appBar: AppBar(title: const Text(AppConstants.appName)),
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
    // Cuando el usuario ya contestó la última pregunta regular, el estado
    // queda en `currentIndex == questions.length`: la siguiente pantalla es
    // la pregunta abierta (o los resultados, si el test ya fue finalizado).
    if (state.currentIndex >= state.questions.length) {
      if (state.isCompleted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) context.go('/result-analysis');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) context.go('/open-question');
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final accentColor = dark ? AppColors.primaryOnDark : AppColors.primary;
    final qIndex = state.currentIndex.clamp(0, state.questions.length - 1).toInt();
    final q = state.questions[qIndex];
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
              colors: dark
                  ? const [AppColors.backgroundDark, AppColors.blue900]
                  : const [AppColors.white, AppColors.blue50],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              child: Column(
                children: [
                  Row(children: [
                    AppBackButton(onPressed: () async {
                      if (await _confirmExit() && context.mounted) context.pop();
                    }),
                    Text(AppConstants.appName,
                        style: AppTypography.headline
                            .copyWith(fontSize: 18, color: accentColor)),
                  ]),
                  const SizedBox(height: AppMetrics.xl),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PROGRESO VOCACIONAL',
                            style: AppTypography.sectionLabel
                                .copyWith(color: accentColor)),
                        Text(
                            'ETAPA ${state.currentIndex + 1} DE ${state.questions.length}',
                            style: AppTypography.sectionLabel
                                .copyWith(color: accentColor)),
                      ]),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppMetrics.radiusChip),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 10,
                      backgroundColor:
                          dark ? AppColors.borderDark : AppColors.blue100,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                  const SizedBox(height: AppMetrics.xxl + AppMetrics.sm),
                  Expanded(
                    child: Center(
                      child: InstitutionalCard(
                        padding: const EdgeInsets.fromLTRB(24, 38, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(q.text,
                                textAlign: TextAlign.center,
                                style: AppTypography.display
                                    .copyWith(fontSize: 24, color: titleColor)),
                            const SizedBox(height: AppMetrics.xxl + AppMetrics.sm),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const _ScaleIcon(
                                  icon: Icons.block_rounded,
                                  label: 'NADA',
                                  active: false),
                              const SizedBox(width: AppMetrics.xxl + AppMetrics.sm),
                              Container(
                                width: 78,
                                height: 78,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: dark
                                      ? AppColors.primaryOnDarkContainer
                                      : AppColors.blue100,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(value.round().toString(),
                                    style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w700,
                                        color: accentColor)),
                              ),
                              const SizedBox(width: AppMetrics.xxl + AppMetrics.sm),
                              const _ScaleIcon(
                                  icon: Icons.input_rounded,
                                  label: 'MUCHO',
                                  active: true),
                            ]),
                            const SizedBox(height: AppMetrics.xl),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 8,
                                activeTrackColor: accentColor,
                                inactiveTrackColor: dark
                                    ? AppColors.borderDark
                                    : AppColors.blue100,
                                thumbColor: accentColor,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 15),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 24),
                              ),
                              child: Slider(
                                  value: value,
                                  min: 0,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (v) => setState(() => value = v)),
                            ),
                            const SizedBox(height: AppMetrics.xl),
                            SizedBox(
                              width: double.infinity,
                              height: AppMetrics.buttonHeight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(testProvider.notifier)
                                      .answerQuestion(value);
                                  final done = await ref
                                      .read(testProvider.notifier)
                                      .nextQuestion();
                                  if (!context.mounted) return;
                                  if (done) {
                                    context.go('/open-question');
                                  } else {
                                    final nextState = ref.read(testProvider);
                                    final nextId = nextState
                                        .questions[nextState.currentIndex].id;
                                    setState(() => value =
                                        nextState.answers[nextId] ?? 5);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  elevation: 3,
                                  shadowColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppMetrics.radiusButton)),
                                ),
                                child: const Text('Continuar  ›',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
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
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = dark ? AppColors.primaryOnDark : AppColors.primary;
    final secondaryColor =
        dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Column(children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: active
              ? (dark
                  ? AppColors.primaryOnDarkContainer
                  : AppColors.blue100)
              : (dark
                  ? AppColors.surfaceVariantDark
                  : AppColors.blue50),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? accentColor : secondaryColor),
      ),
      const SizedBox(height: 7),
      Text(label,
          style: AppTypography.micro
              .copyWith(color: active ? accentColor : secondaryColor)),
    ]);
  }
}
