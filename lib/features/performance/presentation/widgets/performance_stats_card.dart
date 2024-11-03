import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/features/performance/domain/models/performance_stats.dart';

class PerformanceStatsCard extends StatelessWidget {
  final PerformanceStats stats;

  const PerformanceStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
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
                Text(
                  'Performans İstatistikleri',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: _StatItem(
                        title: 'Ortalama Başarı',
                        value: '${stats.averageScore.toStringAsFixed(1)}%',
                        icon: Icons.trending_up_rounded,
                        color: _getScoreColor(stats.averageScore),
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: _StatItem(
                        title: 'Toplam Soru',
                        value: stats.totalQuestions.toString(),
                        icon: Icons.quiz_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: _StatItem(
                        title: 'Doğru',
                        value: stats.totalCorrect.toString(),
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: _StatItem(
                        title: 'Yanlış',
                        value: stats.totalIncorrect.toString(),
                        icon: Icons.cancel_rounded,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                );
              },
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
