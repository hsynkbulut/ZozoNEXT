import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/features/performance/presentation/providers/students_provider.dart';

class StudentSelector extends ConsumerWidget {
  final String? selectedStudentId;
  final ValueChanged<String?> onChanged;

  const StudentSelector({
    super.key,
    required this.selectedStudentId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return studentsAsync.when(
      data: (students) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonFormField<String>(
          value: selectedStudentId,
          decoration: InputDecoration(
            labelText: 'Öğrenci',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'Tüm Öğrenciler',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            ...students.map(
              (student) => DropdownMenuItem(
                value: student.id,
                child: Text(
                  student.name,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          dropdownColor: Colors.white,
          style: AppTextStyles.bodyMedium,
        ),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text(
        'Hata: $error',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}
