import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _S();
}

class _S extends State<SettingsPage> {
  bool reduced = false, dark = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        reduced = p.getBool('reduced_animations') ?? false;
        dark = p.getBool('dark_mode') ?? false;
      });
    }
  }

  Future<void> _save(String k, bool v) async {
    (await SharedPreferences.getInstance()).setBool(k, v);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Configuración')),
    body: ListView(
      children: [
        SwitchListTile(
          title: const Text('Reducir animaciones'),
          value: reduced,
          onChanged: (v) {
            setState(() => reduced = v);
            _save('reduced_animations', v);
          },
        ),
        SwitchListTile(
          title: const Text('Modo oscuro'),
          value: dark,
          onChanged: (v) {
            setState(() => dark = v);
            _save('dark_mode', v);
          },
        ),
      ],
    ),
  );
}
