import 'package:flutter/material.dart';

class DifficultyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const DifficultyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Zorluk Seviyesi',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Kolay', child: Text('Kolay')),
        DropdownMenuItem(value: 'Orta', child: Text('Orta')),
        DropdownMenuItem(value: 'Zor', child: Text('Zor')),
      ],
      onChanged: onChanged,
    );
  }
}
