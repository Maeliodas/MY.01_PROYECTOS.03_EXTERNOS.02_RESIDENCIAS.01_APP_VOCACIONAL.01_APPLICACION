import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final reduceAnimations = ref.watch(reduceAnimationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Alternar entre tema claro y oscuro'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggleTheme(val);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Disminuir Animaciones'),
            subtitle: const Text('Reduce los efectos de movimiento'),
            value: reduceAnimations,
            onChanged: (val) {
              ref.read(reduceAnimationsProvider.notifier).toggleReduce(val);
            },
          ),
        ],
      ),
    );
  }
}
