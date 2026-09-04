import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: const Center(
        child: Text(
          'Aquí se mostrarán tus resultados RIASEC y las carreras recomendadas.',
        ),
      ),
    );
  }
}
