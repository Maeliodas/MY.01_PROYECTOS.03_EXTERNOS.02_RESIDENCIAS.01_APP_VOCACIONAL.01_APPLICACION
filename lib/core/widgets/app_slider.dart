import 'package:flutter/material.dart';

class AppSlider extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  const AppSlider({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext c) {
    final v = value ?? 5;
    return Column(
      children: [
        Slider(
          min: 0,
          max: 9,
          divisions: 9,
          value: v.toDouble(),
          label: value?.toString() ?? 'Selecciona',
          onChanged: (x) => onChanged(x.round()),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('0  Nada'), Text('9  Mucho')],
        ),
      ],
    );
  }
}
