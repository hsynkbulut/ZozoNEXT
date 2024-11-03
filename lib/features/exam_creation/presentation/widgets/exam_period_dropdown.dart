import 'package:flutter/material.dart';

class ExamPeriodDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const ExamPeriodDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<Map<String, String>> examPeriods = [
    {'value': '1. Dönem 1. Yazılı', 'label': '1. Dönem 1. Yazılı'},
    {'value': '1. Dönem 2. Yazılı', 'label': '1. Dönem 2. Yazılı'},
    {'value': '1. Dönem 3. Yazılı', 'label': '1. Dönem 3. Yazılı'},
    {'value': '2. Dönem 1. Yazılı', 'label': '2. Dönem 1. Yazılı'},
    {'value': '2. Dönem 2. Yazılı', 'label': '2. Dönem 2. Yazılı'},
    {'value': '2. Dönem 3. Yazılı', 'label': '2. Dönem 3. Yazılı'},
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Sınav Dönemi',
        border: OutlineInputBorder(),
      ),
      items: examPeriods.map((period) {
        return DropdownMenuItem(
          value: period['value'],
          child: Text(period['label']!),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen sınav dönemini seçin';
        }
        return null;
      },
    );
  }
}
