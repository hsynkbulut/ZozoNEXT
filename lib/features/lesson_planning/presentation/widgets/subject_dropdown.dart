import 'package:flutter/material.dart';

class SubjectDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const SubjectDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Ders',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Matematik', child: Text('Matematik')),
        DropdownMenuItem(value: 'Fizik', child: Text('Fizik')),
        DropdownMenuItem(value: 'Kimya', child: Text('Kimya')),
        DropdownMenuItem(value: 'Biyoloji', child: Text('Biyoloji')),
        DropdownMenuItem(value: 'Türkçe', child: Text('Türkçe')),
        DropdownMenuItem(value: 'Tarih', child: Text('Tarih')),
      ],
      onChanged: onChanged,
    );
  }
}