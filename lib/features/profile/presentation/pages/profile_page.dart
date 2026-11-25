import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/institutional_components.dart';
import '../../../result/presentation/providers/result_provider.dart';
import '../../../test/presentation/providers/test_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../core/constants/app_constants.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(profileProvider);
    final result = ref.watch(latestResultProvider).valueOrNull;
    final historyCount = ref.watch(resultHistoryProvider).valueOrNull?.length ?? 0;
    final test = ref.watch(testProvider);
    final totalQuestions = test.questions.length;
    final progress = test.isCompleted
        ? 1.0
        : totalQuestions == 0 ? 0.0 : (test.answers.length / totalQuestions).clamp(0.0, 1.0).toDouble();
    final progressLabel = '${(progress * 100).round()}%';
    if(profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    final path = profile.avatarConfig.avatarPath;
    final local = path.startsWith('/') || path.contains('emulated');
    final avatar = local ? Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60)) : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60));
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(22, 16, 22, 30), children: [
          Row(children: [Text(AppConstants.appName, style: AppTypography.headline.copyWith(color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)), const Spacer(), IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined))]),
          const SizedBox(height: 16),
          Center(child: Stack(clipBehavior: Clip.none, children: [Container(width: 118, height: 118, padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 4)), child: ClipOval(child: avatar)), Positioned(right: -2, bottom: 3, child: Material(color: AppColors.primary, shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: () => context.push('/edit-profile'), child: const SizedBox(width: 38, height: 38, child: Icon(Icons.edit_rounded, color: AppColors.onPrimary, size: 19)))))])),
          const SizedBox(height: 12),
          Text(profile.name, textAlign: TextAlign.center, style: AppTypography.display.copyWith(color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const SizedBox(height: 6),
          Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: dark ? AppColors.primaryOnDarkContainer : AppColors.secondaryLight, borderRadius: BorderRadius.circular(AppMetrics.radiusChip)), child: Text(result == null ? 'Nivel: Explorador' : 'Perfil ${result.riasec.hollandCode}', style: AppTypography.badge.copyWith(color: dark ? AppColors.primaryOnDark : AppColors.primaryDarker)))),
          const SizedBox(height: 26),
          Row(children: [Expanded(child: _Stat(icon: Icons.check_circle_outline_rounded, title: 'TESTS\nCOMPLETADOS', value: historyCount.toString(), color: dark ? AppColors.primaryOnDark : AppColors.primary)), const SizedBox(width: 14), Expanded(child: _Stat(icon: Icons.school_outlined, title: 'ESCUELA', value: profile.school, color: AppColors.blue400, small: true))]),
          const SizedBox(height: 18),
          InstitutionalCard(
            padding: const EdgeInsets.all(AppMetrics.xl),
            color: dark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Text('Progreso vocacional', style: AppTypography.headline), const Spacer(), Text(progressLabel, style: AppTypography.headline.copyWith(color: dark ? AppColors.primaryOnDark : AppColors.primary))]),
              const SizedBox(height: AppMetrics.md),
              ClipRRect(borderRadius: BorderRadius.circular(AppMetrics.sm), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: dark ? AppColors.borderDark : AppColors.blue100, valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
              const SizedBox(height: AppMetrics.md),
              Text(result == null ? 'Completa tu test para descubrir tu perfil vocacional.' : '¡Buen camino! Tu resultado principal es ${result.topCareer.name}.', style: AppTypography.caption.copyWith(fontSize: 13, height: 1.4, color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 18),
          _Menu(icon: Icons.history_rounded, color: dark ? AppColors.primaryOnDark : AppColors.primary, title: 'Historial', subtitle: 'Revisa tus resultados previos', onTap: () => context.push('/history')),
          _Menu(icon: Icons.edit_rounded, color: AppColors.secondary, title: 'Editar perfil', subtitle: 'Actualiza tu información personal', onTap: () => context.push('/edit-profile')),
          _Menu(icon: Icons.settings_outlined, color: AppColors.blue400, title: 'Configuración', subtitle: 'Preferencias y privacidad', onTap: () => context.push('/settings')),
          _Menu(
            icon: Icons.restart_alt_rounded,
            color: AppColors.destructiveRed,
            title: 'Reiniciar test',
            subtitle: 'Comienza una nueva evaluación desde cero',
            onTap: () => _confirmResetTest(context, ref),
          ),
        ]),
      ),
    );
  }
}
Future<void> _confirmResetTest(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.restart_alt_rounded, size: 42, color: AppColors.destructiveRed),
      title: const Text('¿Reiniciar el test?'),
      content: const Text(
        'Se borrará el progreso actual del test. Tus resultados anteriores permanecerán disponibles en el Historial.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.destructiveRed),
          child: const Text('Reiniciar'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  await ref.read(testProvider.notifier).resetTest();
  if (context.mounted) context.go('/path-home');
}

class _Stat extends StatelessWidget { final IconData icon; final String title; final String value; final Color color; final bool small; const _Stat({required this.icon, required this.title, required this.value, required this.color, this.small=false}); @override Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return Container(height: 140, padding: const EdgeInsets.all(AppMetrics.lg), decoration: BoxDecoration(color: dark ? AppColors.cardBackgroundDark : AppColors.cardBackground, borderRadius: BorderRadius.circular(AppMetrics.radiusLg), border: dark ? Border.all(color: AppColors.borderDark) : null, boxShadow: dark ? AppMetrics.shadowCardDark : AppMetrics.shadowCard), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const Spacer(), Text(title, style: AppTypography.micro.copyWith(color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary)), const SizedBox(height: 5), Text(value, maxLines: small ? 2 : 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: small ? 15 : 26, height: 1.05, fontWeight: FontWeight.w700, color: color))])); } }
class _Menu extends StatelessWidget { final IconData icon; final Color color; final String title; final String subtitle; final VoidCallback onTap; const _Menu({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap}); @override Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return InstitutionalCard(padding: EdgeInsets.zero, margin: const EdgeInsets.only(bottom: AppMetrics.md), child: Material(color: Colors.transparent, child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: AppMetrics.lg, vertical: 5), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: dark ? AppColors.surfaceVariantDark : AppColors.blue50, borderRadius: BorderRadius.circular(AppMetrics.radiusMd)), child: Icon(icon, color: color)), title: Text(title, style: AppTypography.title), subtitle: Text(subtitle, style: AppTypography.caption), trailing: const Icon(Icons.chevron_right_rounded)))); } }
