import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/progress_map.dart';

class ProgressMapPage extends StatelessWidget {
  const ProgressMapPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tu camino')),
    body: ProgressMap(onStartTest: () => context.push('/test')),
  );
}
