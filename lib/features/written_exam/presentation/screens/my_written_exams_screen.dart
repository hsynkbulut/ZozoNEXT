import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_empty_state.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/written_exam/presentation/providers/written_exam_provider.dart';
import 'package:teachmate_pro/features/written_exam/domain/models/written_exam_model.dart';
import 'package:intl/intl.dart';

class MyWrittenExamsScreen extends ConsumerWidget {
  const MyWrittenExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(writtenExamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Yazılı Sınavlarım'),
          ],
        ),
      ),
      body: examsAsync.when(
        data: (exams) {
          if (exams.isEmpty) {
            return AppEmptyState(
              icon: Icons.event_note_rounded,
              title: 'Henüz sınav eklenmemiş',
              message: 'Yeni bir yazılı sınav eklemek için butona tıklayın.',
              buttonText: 'Sınav Ekle',
              onButtonPressed: () => context.push('/add-written-exam'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final isUpcoming = exam.examDate.isAfter(DateTime.now());

              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 16), // Add spacing between items
                child: Dismissible(
                  key: Key(exam.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _showDeleteConfirmation(context),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    ref.read(writtenExamControllerProvider).deleteExam(exam.id);
                    AppSnackBar.showSuccess(
                      context: context,
                      message: 'Sınav silindi',
                    );
                  },
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getSubjectColor(exam.subject)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getSubjectIcon(exam.subject),
                                  color: _getSubjectColor(exam.subject),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.subject,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      exam.examPeriod,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isUpcoming
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.textSecondary
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isUpcoming ? 'Yaklaşan' : 'Tamamlandı',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isUpcoming
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            // Replace Row with Wrap to prevent overflow
                            spacing:
                                8, // Horizontal spacing between wrapped items
                            runSpacing:
                                8, // Vertical spacing between wrapped lines
                            children: [
                              _buildInfoChip(
                                icon: Icons.calendar_today_rounded,
                                label: DateFormat('dd/MM/yyyy')
                                    .format(exam.examDate),
                              ),
                              if (isUpcoming)
                                _buildInfoChip(
                                  icon: Icons.timer_outlined,
                                  label:
                                      '${exam.examDate.difference(DateTime.now()).inDays} gün kaldı',
                                  color: AppColors.primary,
                                ),
                              if (isUpcoming)
                                AppButton(
                                  text: 'Düzenle',
                                  onPressed: () =>
                                      _showEditDialog(context, ref, exam),
                                  variant: AppButtonVariant.text,
                                  icon: Icons.edit_outlined,
                                  size: AppButtonSize.small,
                                  fullWidth: false,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Hata: $error',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-written-exam'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Sınav Ekle'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? AppColors.textSecondary).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik':
        return Icons.functions_rounded;
      case 'fizik':
        return Icons.science_rounded;
      case 'kimya':
        return Icons.science_rounded;
      case 'biyoloji':
        return Icons.biotech_rounded;
      default:
        return Icons.school_rounded;
    }
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

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return AppDialog.showConfirmation(
      context: context,
      title: 'Sınavı Sil',
      message: 'Bu sınavı silmek istediğinizden emin misiniz?',
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDestructive: true,
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    WrittenExam exam,
  ) {
    String selectedSubject = exam.subject;
    String selectedPeriod = exam.examPeriod;
    DateTime selectedDate = exam.examDate;

    return AppDialog.show(
      context: context,
      title: 'Sınavı Düzenle',
      content: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Ders',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    prefixIcon: Icon(
                      Icons.book_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  items: WrittenExam.subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSubject = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedPeriod,
                  decoration: InputDecoration(
                    labelText: 'Sınav Dönemi',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    prefixIcon: Icon(
                      Icons.event_note_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  items: WrittenExam.examPeriods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPeriod = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: AppColors.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sınav Tarihi',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          text: 'İptal',
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          fullWidth: false,
        ),
        AppButton(
          text: 'Kaydet',
          onPressed: () async {
            try {
              await ref.read(writtenExamControllerProvider).updateExam(
                    examId: exam.id,
                    subject: selectedSubject,
                    examPeriod: selectedPeriod,
                    examDate: selectedDate,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                AppSnackBar.showSuccess(
                  context: context,
                  message: 'Sınav başarıyla güncellendi',
                );
              }
            } catch (e) {
              if (context.mounted) {
                AppSnackBar.showError(
                  context: context,
                  message: e.toString(),
                );
              }
            }
          },
          fullWidth: false,
        ),
      ],
    );
  }
}
