import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final int position;
  final String title;
  final double score;
  const ResultCard({
    super.key,
    required this.position,
    required this.title,
    required this.score,
  });
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text('$position')),
      title: Text(title),
      subtitle: LinearProgressIndicator(value: score / 100),
      trailing: Text('${score.toStringAsFixed(0)}%'),
    ),
  );
}
