import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PathHomePage extends StatelessWidget {
  const PathHomePage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Inicio'),
      actions: [
        IconButton(
          onPressed: () => c.push('/profile'),
          icon: const Icon(Icons.person_outline),
        ),
        IconButton(
          onPressed: () => c.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _A(
          'Realizar test vocacional',
          Icons.quiz_outlined,
          () => c.push('/test/intro'),
        ),
        _A(
          'Mis resultados',
          Icons.insights_outlined,
          () => c.push('/result/detail'),
        ),
        _A('Historial', Icons.history, () => c.push('/history')),
        _A(
          'Contacto con el instituto',
          Icons.contact_mail_outlined,
          () => c.push('/path/contact'),
        ),
        _A('Misiones', Icons.flag_outlined, () => c.push('/path/missions')),
      ],
    ),
  );
}

class _A extends StatelessWidget {
  final String t;
  final IconData i;
  final VoidCallback f;
  const _A(this.t, this.i, this.f);
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      leading: Icon(i),
      title: Text(t),
      trailing: const Icon(Icons.chevron_right),
      onTap: f,
    ),
  );
}
