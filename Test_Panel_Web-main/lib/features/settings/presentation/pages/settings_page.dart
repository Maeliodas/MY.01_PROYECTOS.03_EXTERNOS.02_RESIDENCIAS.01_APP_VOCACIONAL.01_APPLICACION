import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final reduce = ref.watch(reduceAnimationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 30), children: [
        const Text('PREFERENCIAS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: 1.1)),
        const SizedBox(height: 10),
        Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(26)), child: Column(children: [
          _Switch(icon: Icons.dark_mode_outlined, iconColor: const Color(0xFF7432CE), title: 'Modo Oscuro', subtitle: 'Reduce la fatiga visual', value: themeMode == ThemeMode.dark, onChanged: (v) => ref.read(themeModeProvider.notifier).toggleTheme(v)),
          const Divider(height: 1, indent: 70),
          _Switch(icon: Icons.animation_rounded, iconColor: const Color(0xFF18A9D3), title: 'Disminuir Animaciones', subtitle: 'Reduce los efectos de movimiento', value: reduce, onChanged: (v) => ref.read(reduceAnimationsProvider.notifier).toggleReduce(v)),
        ])),
        const SizedBox(height: 26),
        const Text('PRIVACIDAD Y SOPORTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: 1.1)),
        const SizedBox(height: 10),
        Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(26)), child: const Column(children: [
          _Info(icon: Icons.lock_outline_rounded, iconColor: Color(0xFF18A9D3), title: 'Privacidad', subtitle: 'Tus datos se almacenan localmente en el dispositivo.'),
          Divider(height: 1, indent: 70),
          _Info(icon: Icons.help_outline_rounded, iconColor: Color(0xFF7432CE), title: 'Ayuda', subtitle: 'AEVUM ITER · Prototipo funcional Alpha'),
        ])),
        const SizedBox(height: 28),
        Center(child: Text('AEVUM ITER · TUXTEPEC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55), letterSpacing: 1.4))),
      ]),
    );
  }
}
class _Switch extends StatelessWidget { final IconData icon; final Color iconColor; final String title; final String subtitle; final bool value; final ValueChanged<bool> onChanged; const _Switch({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.value, required this.onChanged}); @override Widget build(BuildContext context) => SwitchListTile.adaptive(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), secondary: Container(width: 42, height: 42, decoration: BoxDecoration(color: iconColor.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: iconColor)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), activeThumbColor: AppColors.primary, value: value, onChanged: onChanged); }
class _Info extends StatelessWidget { final IconData icon; final Color iconColor; final String title; final String subtitle; const _Info({required this.icon, required this.iconColor, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: iconColor.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: iconColor)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right_rounded)); }
