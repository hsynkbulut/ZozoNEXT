import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dropdown.dart';

class QuizSettingsCard extends StatelessWidget {
  final String selectedDifficulty;
  final int questionCount;
  final int duration;
  final ValueChanged<String?> onDifficultyChanged;
  final ValueChanged<int> onQuestionCountChanged;
  final ValueChanged<int> onDurationChanged;

  const QuizSettingsCard({
    super.key,
    required this.selectedDifficulty,
    required this.questionCount,
    required this.duration,
    required this.onDifficultyChanged,
    required this.onQuestionCountChanged,
    required this.onDurationChanged,
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
                    Icons.settings_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quiz Ayarları',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppDropdown<String>(
              value: selectedDifficulty,
              label: 'Zorluk Seviyesi',
              items: const [
                DropdownMenuItem(value: 'Kolay', child: Text('Kolay')),
                DropdownMenuItem(value: 'Orta', child: Text('Orta')),
                DropdownMenuItem(value: 'Zor', child: Text('Zor')),
              ],
              onChanged: onDifficultyChanged,
              prefixIcon: Icons.signal_cellular_alt,
            ),
            const SizedBox(height: 16),
            Text(
              'Soru Sayısı: $questionCount',
              style: AppTextStyles.titleMedium,
            ),
            Slider(
              value: questionCount.toDouble(),
              min: 5,
              max: 20,
              divisions: 15,
              label: questionCount.toString(),
              activeColor: AppColors.primary,
              onChanged: (value) => onQuestionCountChanged(value.round()),
            ),
            const SizedBox(height: 16),
            Text(
              'Süre: $duration dakika',
              style: AppTextStyles.titleMedium,
            ),
            Slider(
              value: duration.toDouble(),
              min: 20,
              max: 120,
              divisions: 20,
              label: '$duration dakika',
              activeColor: AppColors.primary,
              onChanged: (value) => onDurationChanged(value.round()),
            ),
          ],
        ),
      ),
    );
  }
}
