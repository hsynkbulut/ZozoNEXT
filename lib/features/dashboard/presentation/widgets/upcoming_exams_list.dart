import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/features/written_exam/presentation/providers/written_exam_provider.dart';
import 'package:intl/intl.dart';

class UpcomingExamsList extends ConsumerWidget {
  const UpcomingExamsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(nextWrittenExamsProvider);

    return examsAsync.when(
      data: (exams) {
        if (exams.isEmpty) {
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Yaklaşan sınav bulunmuyor',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            ...exams.map((exam) {
              final now = DateTime.now();
              final examDate = DateTime(
                exam.examDate.year,
                exam.examDate.month,
                exam.examDate.day,
              );
              final today = DateTime(now.year, now.month, now.day);
              final daysLeft = examDate.difference(today).inDays;
              final isToday = daysLeft == 0;

              return AppCard(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getSubjectColor(exam.subject).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event_note_rounded,
                      color: _getSubjectColor(exam.subject),
                    ),
                  ),
                  title: Text(
                    exam.subject,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    exam.examPeriod,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(exam.examDate),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isToday ? 'Bugün' : '$daysLeft gün kaldı',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Hata: $error',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik':
        return AppColors.primary;
      case 'fizik':
        return AppColors.secondary;
      case 'kimya':
        return AppColors.success;
      case 'biyoloji':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
