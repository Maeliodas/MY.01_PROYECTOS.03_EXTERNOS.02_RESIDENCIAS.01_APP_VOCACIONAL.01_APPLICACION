import 'package:flutter/material.dart';

class SimpleAvatarEditorPage extends StatelessWidget {
  const SimpleAvatarEditorPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Editar avatar')),
    body: const Center(child: Text('Editor de avatar')),
  );
}
