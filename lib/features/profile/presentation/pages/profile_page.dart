import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Perfil')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(child: CircleAvatar(radius: 56, child: Icon(Icons.person, size: 70))),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: () => context.push('/avatar-customization'), icon: const Icon(Icons.edit), label: const Text('Personalizar avatar')),
        const SizedBox(height: 20),
        const Card(child: ListTile(leading: Icon(Icons.school_outlined), title: Text('Escuela de procedencia'))),
        const Card(child: ListTile(leading: Icon(Icons.translate), title: Text('Lenguas'))),
      ],
    ),
  );
}
