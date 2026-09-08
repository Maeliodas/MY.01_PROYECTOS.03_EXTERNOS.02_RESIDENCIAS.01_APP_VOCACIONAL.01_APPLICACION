import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../result/presentation/providers/result_provider.dart';
import '../../../test/presentation/providers/test_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final result = ref.watch(latestResultProvider).valueOrNull;
    final historyCount = ref.watch(resultHistoryProvider).valueOrNull?.length ?? 0;
    if(profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    final path = profile.avatarConfig.avatarPath;
    final local = path.startsWith('/') || path.contains('emulated');
    final avatar = local ? Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60)) : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60));
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(22, 16, 22, 30), children: [
          Row(children: [const Text('Aevum Iter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF287400))), const Spacer(), IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined))]),
          const SizedBox(height: 16),
          Center(child: Stack(clipBehavior: Clip.none, children: [Container(width: 118, height: 118, padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 4)), child: ClipOval(child: avatar)), Positioned(right: -2, bottom: 3, child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF7B35D4), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 19))) ])),
          const SizedBox(height: 12),
          Text(profile.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFDFF3FF), borderRadius: BorderRadius.circular(12)), child: Text(result == null ? 'Nivel: Explorador' : 'Perfil ${result.riasec.hollandCode}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF176C9D))))),
          const SizedBox(height: 26),
          Row(children: [Expanded(child: _Stat(icon: Icons.check_circle_outline_rounded, title: 'TESTS\nCOMPLETADOS', value: historyCount.toString(), color: const Color(0xFF287400))), const SizedBox(width: 14), Expanded(child: _Stat(icon: Icons.school_outlined, title: 'ESCUELA', value: profile.school, color: const Color(0xFF6C2BC8), small: true))]),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(26)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Text('Progreso vocacional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), Text(result == null ? '25%' : '100%', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF287400)))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: result == null ? .25 : 1, minHeight: 8, backgroundColor: const Color(0xFFDCE5D4), valueColor: const AlwaysStoppedAnimation(Color(0xFF18A9D3)))), const SizedBox(height: 12), Text(result == null ? 'Completa tu test para descubrir tu perfil vocacional.' : '¡Buen camino! Tu resultado principal es ${result.topCareer.name}.', style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68)))])),
          const SizedBox(height: 18),
          _Menu(icon: Icons.history_rounded, color: const Color(0xFF18A9D3), title: 'Historial', subtitle: 'Revisa tus resultados previos', onTap: () => context.push('/history')),
          _Menu(icon: Icons.edit_rounded, color: const Color(0xFF7B35D4), title: 'Editar perfil', subtitle: 'Actualiza tu información personal', onTap: () => context.push('/edit-profile')),
          _Menu(icon: Icons.settings_outlined, color: const Color(0xFF287400), title: 'Configuración', subtitle: 'Preferencias y privacidad', onTap: () => context.push('/settings')),
          _Menu(
            icon: Icons.restart_alt_rounded,
            color: const Color(0xFFE86A35),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      icon: const Icon(Icons.restart_alt_rounded, size: 42, color: Color(0xFFE86A35)),
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
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE86A35)),
          child: const Text('Reiniciar'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  await ref.read(testProvider.notifier).resetTest();
  if (context.mounted) context.go('/path-home');
}

class _Stat extends StatelessWidget { final IconData icon; final String title; final String value; final Color color; final bool small; const _Stat({required this.icon, required this.title, required this.value, required this.color, this.small=false}); @override Widget build(BuildContext context) => Container(height: 140, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0,6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const Spacer(), Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .7)), const SizedBox(height: 5), Text(value, maxLines: small ? 2 : 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: small ? 15 : 26, height: 1.05, fontWeight: FontWeight.w900, color: color))])); }
class _Menu extends StatelessWidget { final IconData icon; final Color color; final String title; final String subtitle; final VoidCallback onTap; const _Menu({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap}); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(22)), child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded))); }
