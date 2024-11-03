import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:teachmate_pro/features/exam_creation/domain/models/exam_model.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/providers/exam_provider.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/exam_pdf_preview.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/question_editor.dart';

class ExamEditorScreen extends ConsumerStatefulWidget {
  final List<ExamQuestion> initialQuestions;
  final Map<String, dynamic> examInfo;

  const ExamEditorScreen({
    super.key,
    required this.initialQuestions,
    required this.examInfo,
  });

  @override
  ConsumerState<ExamEditorScreen> createState() => _ExamEditorScreenState();
}

class _ExamEditorScreenState extends ConsumerState<ExamEditorScreen> {
  late List<ExamQuestion> _questions;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.initialQuestions);
  }

  Future<void> _saveExam({bool publish = false}) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final isEditing = widget.examInfo['isEditing'] == true;
      final examId = isEditing
          ? widget.examInfo['id']
          : FirebaseFirestore.instance.collection('exams').doc().id;
      final now = DateTime.now();

      final exam = ExamModel(
        id: examId,
        teacherId: user.id,
        teacherName: user.name,
        schoolName: user.schoolName,
        subject: widget.examInfo['subject'],
        grade: widget.examInfo['grade'],
        topics: widget.examInfo['topics'],
        difficulty: widget.examInfo['difficulty'],
        questions: _questions,
        academicYear: widget.examInfo['academicYear'],
        examTerm: widget.examInfo['examPeriod'],
        duration: widget.examInfo['duration'],
        createdAt: isEditing ? now : now,
        updatedAt: now,
      );

      if (isEditing) {
        await ref.read(examControllerProvider).updateExam(exam);
      } else {
        await ref.read(examControllerProvider).saveExam(exam);
      }

      if (mounted) {
        AppSnackBar.showSuccess(
          context: context,
          message: isEditing
              ? 'Sınav başarıyla güncellendi'
              : 'Sınav başarıyla kaydedildi',
        );
        Navigator.of(context).pop();
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

  void _showPdfPreview() {
    showDialog(
      context: context,
      builder: (context) => ExamPdfPreview(
        questions: _questions,
        examInfo: widget.examInfo,
      ),
    );
  }

  void _showDiscardChangesDialog() {
    if (!_hasChanges) {
      Navigator.of(context).pop();
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
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.examInfo['isEditing'] == true;

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
              Text(
                isEditing ? 'Sınavı Düzenle' : 'Sınavı Düzenle',
                style: AppTextStyles.titleLarge,
              ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            text: 'PDF',
                            onPressed: _showPdfPreview,
                            icon: Icons.picture_as_pdf_outlined,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            fullWidth: false,
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Kaydet',
                            onPressed: _isSaving ? null : () => _saveExam(),
                            icon: Icons.save_outlined,
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
                                        'Sınav Bilgileri',
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
                                    '${widget.examInfo['subject']} - ${widget.examInfo['grade']}. Sınıf',
                                    Icons.subject,
                                  ),
                                  _buildInfoRow(
                                    'Konular',
                                    widget.examInfo['topics'].join(', '),
                                    Icons.topic_outlined,
                                  ),
                                  _buildInfoRow(
                                    'Zorluk',
                                    widget.examInfo['difficulty'],
                                    Icons.signal_cellular_alt,
                                  ),
                                  _buildInfoRow(
                                    'Süre',
                                    '${widget.examInfo['duration']} dakika',
                                    Icons.timer_outlined,
                                  ),
                                  _buildInfoRow(
                                    'Dönem',
                                    widget.examInfo['examPeriod'],
                                    Icons.calendar_today_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          QuestionEditor(
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
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
