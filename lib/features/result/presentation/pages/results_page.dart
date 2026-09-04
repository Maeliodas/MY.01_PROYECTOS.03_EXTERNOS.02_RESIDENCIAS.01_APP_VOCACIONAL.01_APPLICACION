import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: AppBar(title: Text('Resultados')),
    body: Center(child: Text('Aquí se mostrarán tus resultados RIASEC y las carreras recomendadas.')),
  );
}
