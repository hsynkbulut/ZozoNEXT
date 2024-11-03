import 'package:flutter/material.dart';

class GradeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const GradeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Sınıf',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: '9', child: Text('9. Sınıf')),
        DropdownMenuItem(value: '10', child: Text('10. Sınıf')),
        DropdownMenuItem(value: '11', child: Text('11. Sınıf')),
        DropdownMenuItem(value: '12', child: Text('12. Sınıf')),
      ],
      onChanged: onChanged,
    );
  }
}