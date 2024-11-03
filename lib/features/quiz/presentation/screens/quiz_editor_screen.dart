import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';
import 'package:teachmate_pro/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:teachmate_pro/features/quiz/presentation/widgets/quiz_editor.dart';

class QuizEditorScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizEditorScreen({
    super.key,
    required this.quiz,
  });

  @override
  ConsumerState<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends ConsumerState<QuizEditorScreen> {
  late List<QuizQuestion> _questions;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.quiz.questions);
  }

  Future<void> _saveQuiz() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedQuiz = widget.quiz.copyWith(
        questions: _questions,
        updatedAt: DateTime.now(),
      );

      await ref.read(quizControllerProvider).updateQuiz(updatedQuiz);

      if (mounted) {
        AppSnackBar.showSuccess(
          context: context,
          message: 'Quiz başarıyla güncellendi',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showDiscardChangesDialog() {
    if (!_hasChanges) {
      context.pop();
      return;
    }

    AppDialog.showConfirmation(
      context: context,
      title: 'Değişiklikleri Kaydetmediniz',
      message:
          'Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinizden emin misiniz?',
      confirmText: 'Çık',
      cancelText: 'İptal',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showDiscardChangesDialog();
        return false;
      },
      child: Scaffold(
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
                  Icons.edit_document,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Quiz Düzenle'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showDiscardChangesDialog,
          ),
          actions: [
            AppButton(
              text: 'Kaydet',
              onPressed: _isSaving ? null : _saveQuiz,
              icon: Icons.save_outlined,
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
              isLoading: _isSaving,
              fullWidth: false,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
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
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Quiz Bilgileri',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Ders',
                        '${widget.quiz.subject} - ${widget.quiz.grade}. Sınıf',
                        Icons.subject,
                      ),
                      _buildInfoRow(
                        'Konu',
                        widget.quiz.topic,
                        Icons.topic_outlined,
                      ),
                      _buildInfoRow(
                        'Zorluk',
                        widget.quiz.difficulty,
                        Icons.signal_cellular_alt,
                      ),
                      _buildInfoRow(
                        'Süre',
                        '${widget.quiz.duration} dakika',
                        Icons.timer_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              QuizEditor(
                questions: _questions,
                onQuestionsUpdated: (questions) {
                  setState(() {
                    _questions = questions;
                    _hasChanges = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
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
}
