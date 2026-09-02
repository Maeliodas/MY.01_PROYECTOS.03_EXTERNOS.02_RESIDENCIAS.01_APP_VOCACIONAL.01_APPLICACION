import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String id;
  final double radius;
  const AvatarCircle({super.key, required this.id, this.radius = 32});
  @override
  Widget build(BuildContext c) =>
      CircleAvatar(radius: radius, child: Text(id.isEmpty ? '?' : id));
}
