import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int value = 5;
  bool touched = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Test vocacional')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const LinearProgressIndicator(value: 1/30),
          const Spacer(),
          const Text('Me gusta resolver problemas y descubrir cómo funcionan las cosas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 40),
          Text('$value', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          Slider(
            min: 0, max: 9, divisions: 9, value: value.toDouble(),
            onChanged: (v) => setState(() { value = v.round(); touched = true; }),
          ),
          const Spacer(),
          FilledButton(
            onPressed: touched ? () => context.go('/results') : null,
            child: const Text('Continuar'),
          ),
        ],
      ),
    ),
  );
}
