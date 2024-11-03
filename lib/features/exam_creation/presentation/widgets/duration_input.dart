import 'package:flutter/material.dart';

class DurationInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const DurationInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Sınav Süresi: $value dakika',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          flex: 2,
          child: Slider(
            value: value.toDouble(),
            min: 20,
            max: 120,
            divisions: 20,
            label: '$value dakika',
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
      ],
    );
  }
}
