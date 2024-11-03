import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';
import 'package:teachmate_pro/core/widgets/formatted_ai_content.dart';
import 'package:teachmate_pro/features/ai/presentation/providers/ai_provider.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/providers/lesson_plan_provider.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/widgets/subject_dropdown.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/widgets/grade_dropdown.dart';

class LessonPlanScreen extends ConsumerStatefulWidget {
  const LessonPlanScreen({super.key});

  @override
  ConsumerState<LessonPlanScreen> createState() => _LessonPlanScreenState();
}

class _LessonPlanScreenState extends ConsumerState<LessonPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String _selectedSubject = 'Matematik';
  String _selectedGrade = '9';
  String? _generatedPlan;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _generatedPlan = null;
    });

    try {
      final plan = await ref.read(aiControllerProvider).generateLessonPlan(
            subject: _selectedSubject,
            grade: _selectedGrade,
            topic: _topicController.text,
          );

      setState(() {
        _generatedPlan = plan;
      });
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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePlan() async {
    if (_generatedPlan == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(lessonPlanControllerProvider).saveLessonPlan(
            subject: _selectedSubject,
            grade: _selectedGrade,
            topic: _topicController.text,
            content: _generatedPlan!,
          );

      if (mounted) {
        AppSnackBar.showSuccess(
          context: context,
          message: 'Plan başarıyla kaydedildi',
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Planı Oluştur'),
        actions: [
          AppButton(
            text: 'Planlarım',
            onPressed: () => context.push('/my-plans'),
            variant: AppButtonVariant.primary,
            icon: Icons.folder_outlined,
            size: AppButtonSize.small,
            fullWidth: false,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SubjectDropdown(
                        value: _selectedSubject,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSubject = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      GradeDropdown(
                        value: _selectedGrade,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGrade = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _topicController,
                        label: 'Konu',
                        hint: 'Örn: İkinci Dereceden Denklemler',
                        prefixIcon: Icons.topic_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir konu girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Plan Oluştur',
                        onPressed: _isLoading ? null : _generatePlan,
                        isLoading: _isLoading,
                        icon: Icons.auto_awesome_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              if (_generatedPlan != null) ...[
                const SizedBox(height: 24),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Oluşturulan Plan',
                              style: AppTextStyles.titleLarge,
                            ),
                            const SizedBox(width: 15),
                            AppButton(
                              text: 'Kaydet',
                              onPressed: _isSaving ? null : _savePlan,
                              isLoading: _isSaving,
                              icon: Icons.save_outlined,
                              variant: AppButtonVariant.primary,
                              size: AppButtonSize.small,
                              fullWidth: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FormattedAIContent(content: _generatedPlan!),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
