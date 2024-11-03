import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';
import 'package:teachmate_pro/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:teachmate_pro/features/quiz/presentation/widgets/quiz_editor.dart';

class QuizPreviewScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizPreviewScreen({
    super.key,
    required this.quiz,
  });

  @override
  ConsumerState<QuizPreviewScreen> createState() => _QuizPreviewScreenState();
}

class _QuizPreviewScreenState extends ConsumerState<QuizPreviewScreen> {
  late QuizModel _quiz;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quiz = widget.quiz;
  }

  Future<void> _saveQuiz({bool publish = false}) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedQuiz = _quiz.copyWith(
        isPublished: publish,
        updatedAt: DateTime.now(),
      );

      await ref.read(quizControllerProvider).saveQuiz(updatedQuiz);

      if (mounted) {
        AppSnackBar.showSuccess(
          context: context,
          message: publish
              ? 'Quiz başarıyla yayınlandı'
              : 'Quiz başarıyla kaydedildi',
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

  void _showPublishConfirmation() {
    AppDialog.showConfirmation(
      context: context,
      title: 'Quizi Yayınla',
      message: 'Quizi yayınlamak istediğinizden emin misiniz? '
          'Yayınlandıktan sonra öğrenciler bu quizi görüntüleyebilecek.',
      confirmText: 'Yayınla',
      cancelText: 'İptal',
    ).then((confirmed) {
      if (confirmed == true) {
        _saveQuiz(publish: true);
      }
    });
  }

  void _showDiscardChangesDialog() {
    if (!_hasChanges) {
      context.pop();
      return;
    }

    AppDialog.showConfirmation(
      context: context,
      title: 'Değişiklikleri Kaydetmediniz',
      message: 'Yaptığınız değişiklikler kaydedilmedi. '
          'Çıkmak istediğinizden emin misiniz?',
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
                  Icons.preview_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Quiz Önizleme'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showDiscardChangesDialog,
          ),
        ),
        body: _isSaving
            ? const Center(child: AppLoadingIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AppButton(
                            text: 'Kaydet',
                            onPressed: _isSaving ? null : () => _saveQuiz(),
                            icon: Icons.save_outlined,
                            variant: AppButtonVariant.text,
                            size: AppButtonSize.small,
                            isLoading: _isSaving,
                            fullWidth: false,
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Yayınla',
                            onPressed:
                                _isSaving ? null : _showPublishConfirmation,
                            icon: Icons.publish_outlined,
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.small,
                            isLoading: _isSaving,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                        style:
                                            AppTextStyles.titleLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    'Ders',
                                    '${_quiz.subject} - ${_quiz.grade}. Sınıf',
                                    Icons.subject,
                                  ),
                                  _buildInfoRow(
                                    'Konu',
                                    _quiz.topic,
                                    Icons.topic_outlined,
                                  ),
                                  _buildInfoRow(
                                    'Zorluk',
                                    _quiz.difficulty,
                                    Icons.signal_cellular_alt,
                                  ),
                                  _buildInfoRow(
                                    'Süre',
                                    '${_quiz.duration} dakika',
                                    Icons.timer_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          QuizEditor(
                            questions: _quiz.questions,
                            onQuestionsUpdated: (questions) {
                              setState(() {
                                _quiz = _quiz.copyWith(questions: questions);
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),
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
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
