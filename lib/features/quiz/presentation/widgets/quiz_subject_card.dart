import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dropdown.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';

class QuizSubjectCard extends StatelessWidget {
  final String selectedSubject;
  final String selectedGrade;
  final TextEditingController topicController;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<String?> onGradeChanged;

  const QuizSubjectCard({
    super.key,
    required this.selectedSubject,
    required this.selectedGrade,
    required this.topicController,
    required this.onSubjectChanged,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quiz Detayları',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppDropdown<String>(
              value: selectedSubject,
              label: 'Ders',
              items: const [
                DropdownMenuItem(value: 'Matematik', child: Text('Matematik')),
                DropdownMenuItem(value: 'Fizik', child: Text('Fizik')),
                DropdownMenuItem(value: 'Kimya', child: Text('Kimya')),
                DropdownMenuItem(value: 'Biyoloji', child: Text('Biyoloji')),
              ],
              onChanged: onSubjectChanged,
              prefixIcon: Icons.subject,
            ),
            const SizedBox(height: 16),
            AppDropdown<String>(
              value: selectedGrade,
              label: 'Sınıf',
              items: const [
                DropdownMenuItem(value: '9', child: Text('9. Sınıf')),
                DropdownMenuItem(value: '10', child: Text('10. Sınıf')),
                DropdownMenuItem(value: '11', child: Text('11. Sınıf')),
                DropdownMenuItem(value: '12', child: Text('12. Sınıf')),
              ],
              onChanged: onGradeChanged,
              prefixIcon: Icons.grade,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: topicController,
              label: 'Konu',
              hint: 'Örn: İkinci Dereceden Denklemler',
              prefixIcon: Icons.topic_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir konu girin';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
