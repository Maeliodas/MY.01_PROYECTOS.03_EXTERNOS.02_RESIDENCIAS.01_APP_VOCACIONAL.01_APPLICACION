import 'package:flutter/material.dart';

class ProgressHeader extends StatelessWidget {
  final int current, total;
  const ProgressHeader({super.key, required this.current, required this.total});
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('ETAPA $current DE $total'),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: current / total),
    ],
  );
}
