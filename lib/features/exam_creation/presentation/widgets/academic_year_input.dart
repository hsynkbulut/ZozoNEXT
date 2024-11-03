import 'package:flutter/material.dart';

class AcademicYearInput extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const AcademicYearInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Eğitim Yılı',
        hintText: '2023-2024',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Eğitim yılı zorunludur';
        }
        if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value)) {
          return 'Geçerli bir eğitim yılı girin (örn: 2023-2024)';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
