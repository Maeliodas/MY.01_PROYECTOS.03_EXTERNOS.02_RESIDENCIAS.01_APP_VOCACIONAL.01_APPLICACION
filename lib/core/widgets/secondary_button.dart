import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryButton({super.key, required this.label, this.onPressed});
  @override
  Widget build(BuildContext c) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(onPressed: onPressed, child: Text(label)),
  );
}
