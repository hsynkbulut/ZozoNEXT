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
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';
import 'package:teachmate_pro/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class MyQuizzesScreen extends ConsumerWidget {
  const MyQuizzesScreen({super.key});

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
                    Icons.quiz_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Quizlerim'),
              ],
            ),
          ),
          body: StreamBuilder<List<QuizModel>>(
            stream: ref.read(quizControllerProvider).getTeacherQuizzes(user.id),
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

              final quizzes = snapshot.data ?? [];

              if (quizzes.isEmpty) {
                return AppEmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'Henüz quiz oluşturmadınız',
                  message: 'Yeni bir quiz oluşturmak için butona tıklayın.',
                  buttonText: 'Quiz Oluştur',
                  onButtonPressed: () => context.push('/quiz-creation'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: quizzes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _QuizCard(quiz: quizzes[index]);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/quiz-creation'),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Quiz'),
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

class _QuizCard extends ConsumerWidget {
  final QuizModel quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${quiz.subject} - ${quiz.grade}. Sınıf',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: quiz.isPublished
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    quiz.isPublished ? 'Yayında' : 'Taslak',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: quiz.isPublished
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  quiz.topic,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Son güncelleme: ${DateFormat.yMMMd().add_Hm().format(quiz.updatedAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  'Zorluk',
                  quiz.difficulty,
                  Icons.signal_cellular_alt_outlined,
                ),
                _buildInfoRow(
                  context,
                  'Süre',
                  '${quiz.duration} dakika',
                  Icons.timer_outlined,
                ),
                _buildInfoRow(
                  context,
                  'Soru Sayısı',
                  '${quiz.questions.length}',
                  Icons.quiz_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Önizle',
                      onPressed: () =>
                          context.push('/quiz-preview', extra: quiz),
                      icon: Icons.visibility_outlined,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      fullWidth: false,
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Düzenle',
                      onPressed: () =>
                          context.push('/quiz-editor', extra: quiz),
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
      title: 'Quizi Sil',
      message:
          'Bu quizi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await ref.read(quizControllerProvider).deleteQuiz(quiz.id);
        if (context.mounted) {
          AppSnackBar.showSuccess(
            context: context,
            message: 'Quiz başarıyla silindi',
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
