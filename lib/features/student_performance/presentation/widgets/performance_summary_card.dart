import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_data.dart';

class PerformanceSummaryCard extends StatelessWidget {
  final List<StudentPerformanceData> data;

  const PerformanceSummaryCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions =
        data.fold<int>(0, (sum, item) => sum + item.totalQuestions);
    final totalCorrect =
        data.fold<int>(0, (sum, item) => sum + item.correctCount);
    final totalWrong = data.fold<int>(0, (sum, item) => sum + item.wrongCount);
    final totalUnanswered =
        data.fold<int>(0, (sum, item) => sum + item.unansweredCount);
    final averageScore =
        data.fold<double>(0, (sum, item) => sum + item.totalScore) /
            data.length;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Performans Özeti',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    title: 'Ortalama Başarı',
                    value: '${averageScore.toStringAsFixed(1)}%',
                    icon: Icons.trending_up_rounded,
                    color: _getScoreColor(averageScore),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    title: 'Toplam Soru',
                    value: totalQuestions.toString(),
                    icon: Icons.quiz_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    title: 'Doğru',
                    value: totalCorrect.toString(),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    title: 'Yanlış',
                    value: totalWrong.toString(),
                    icon: Icons.cancel_rounded,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    title: 'Boş',
                    value: totalUnanswered.toString(),
                    icon: Icons.remove_circle_outline_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.primary;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
