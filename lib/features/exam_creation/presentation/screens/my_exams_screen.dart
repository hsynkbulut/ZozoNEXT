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
import 'package:teachmate_pro/features/exam_creation/domain/models/exam_model.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/providers/exam_provider.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class MyExamsScreen extends ConsumerWidget {
  const MyExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Kullanıcı oturumu bulunamadı'),
            ),
          );
        }

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
                    Icons.assignment_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Sınavlarım'),
              ],
            ),
          ),
          body: StreamBuilder<List<ExamModel>>(
            stream: ref.read(examControllerProvider).getTeacherExams(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AppLoadingIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Hata: ${snapshot.error}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                );
              }

              final exams = snapshot.data ?? [];

              if (exams.isEmpty) {
                return AppEmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'Henüz sınav oluşturmadınız',
                  message: 'Yeni bir sınav oluşturmak için butona tıklayın.',
                  buttonText: 'Sınav Oluştur',
                  onButtonPressed: () => context.push('/exam-creation'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: exams.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _ExamCard(exam: exams[index]);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/exam-creation'),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Sınav'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: AppLoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            'Hata: $error',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends ConsumerWidget {
  final ExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '${exam.subject} - ${exam.grade}. Sınıf',
              style: AppTextStyles.titleLarge,
            ),
            subtitle: Text(
              'Konular: ${exam.topics.join(", ")}\n'
              'Güncellenme: ${DateFormat.yMMMd().add_Hm().format(exam.updatedAt)}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 24),
                _buildInfoRow(
                  context,
                  'Zorluk',
                  exam.difficulty,
                  Icons.signal_cellular_alt,
                ),
                _buildInfoRow(
                  context,
                  'Süre',
                  '${exam.duration} dakika',
                  Icons.timer_outlined,
                ),
                _buildInfoRow(
                  context,
                  'Soru Sayısı',
                  '${exam.questions.length}',
                  Icons.quiz_outlined,
                ),
                _buildInfoRow(
                  context,
                  'Dönem',
                  exam.examTerm,
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'PDF',
                      onPressed: () => context.push('/exam-preview', extra: {
                        'questions': exam.questions,
                        'examInfo': {
                          'subject': exam.subject,
                          'grade': exam.grade,
                          'academicYear': exam.academicYear,
                          'examPeriod': exam.examTerm,
                          'duration': exam.duration,
                          'schoolName': exam.schoolName,
                          'teacherName': exam.teacherName,
                        },
                      }),
                      icon: Icons.picture_as_pdf_outlined,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      fullWidth: false,
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Düzenle',
                      onPressed: () => context.push('/exam-editor', extra: {
                        'questions': exam.questions,
                        'examInfo': {
                          'id': exam.id,
                          'subject': exam.subject,
                          'grade': exam.grade,
                          'topics': exam.topics,
                          'difficulty': exam.difficulty,
                          'academicYear': exam.academicYear,
                          'examPeriod': exam.examTerm,
                          'duration': exam.duration,
                          'isEditing': true,
                        },
                      }),
                      icon: Icons.edit_outlined,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      fullWidth: false,
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Sil',
                      onPressed: () => _showDeleteConfirmation(context, ref),
                      icon: Icons.delete_outline,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      fullWidth: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Sınavı Sil',
      message:
          'Bu sınavı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await ref.read(examControllerProvider).deleteExam(exam.id);
        if (context.mounted) {
          AppSnackBar.showSuccess(
            context: context,
            message: 'Sınav başarıyla silindi',
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
    }
  }
}
