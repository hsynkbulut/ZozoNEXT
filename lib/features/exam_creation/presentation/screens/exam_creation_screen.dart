import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dropdown.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/providers/exam_provider.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/academic_year_input.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/difficulty_dropdown.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/duration_input.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/exam_period_dropdown.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/topic_input.dart';

class ExamCreationScreen extends ConsumerStatefulWidget {
  const ExamCreationScreen({super.key});

  @override
  ConsumerState<ExamCreationScreen> createState() => _ExamCreationScreenState();
}

class _ExamCreationScreenState extends ConsumerState<ExamCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSubject = 'Matematik';
  String _selectedGrade = '9';
  List<String> _topics = [];
  String _selectedDifficulty = 'Orta';
  int _questionCount = 10;
  String _academicYear = '2023-2024';
  String _selectedExamPeriod = '1. Dönem 1. Yazılı';
  int _duration = 40;
  bool _isLoading = false;

  Future<void> _generateExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_topics.isEmpty) {
      AppSnackBar.showWarning(
        context: context,
        message: 'En az bir konu girmelisiniz',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions = await ref.read(examControllerProvider).generateExam(
            grade: _selectedGrade,
            subject: _selectedSubject,
            topics: _topics,
            difficulty: _selectedDifficulty,
            questionCount: _questionCount,
          );

      if (mounted) {
        context.push('/exam-editor', extra: {
          'questions': questions,
          'examInfo': {
            'subject': _selectedSubject,
            'grade': _selectedGrade,
            'topics': _topics,
            'difficulty': _selectedDifficulty,
            'academicYear': _academicYear,
            'examPeriod': _selectedExamPeriod,
            'duration': _duration,
          },
        });
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Sınav Oluştur',
        ),
        actions: [
          AppButton(
            text: 'Sınavlarım',
            onPressed: () => context.push('/my-exams'),
            variant: AppButtonVariant.primary,
            icon: Icons.folder_outlined,
            size: AppButtonSize.small,
            fullWidth: false,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : SingleChildScrollView(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yazılı Sınav Bilgileri',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppDropdown<String>(
                              value: _selectedSubject,
                              label: 'Ders',
                              items: const [
                                DropdownMenuItem(
                                  value: 'Matematik',
                                  child: Text('Matematik'),
                                ),
                                DropdownMenuItem(
                                  value: 'Fizik',
                                  child: Text('Fizik'),
                                ),
                                DropdownMenuItem(
                                  value: 'Kimya',
                                  child: Text('Kimya'),
                                ),
                                DropdownMenuItem(
                                  value: 'Biyoloji',
                                  child: Text('Biyoloji'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSubject = value;
                                  });
                                }
                              },
                              prefixIcon: Icons.subject,
                            ),
                            const SizedBox(height: 16),
                            AppDropdown<String>(
                              value: _selectedGrade,
                              label: 'Sınıf',
                              items: const [
                                DropdownMenuItem(
                                  value: '9',
                                  child: Text('9. Sınıf'),
                                ),
                                DropdownMenuItem(
                                  value: '10',
                                  child: Text('10. Sınıf'),
                                ),
                                DropdownMenuItem(
                                  value: '11',
                                  child: Text('11. Sınıf'),
                                ),
                                DropdownMenuItem(
                                  value: '12',
                                  child: Text('12. Sınıf'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGrade = value;
                                  });
                                }
                              },
                              prefixIcon: Icons.school,
                            ),
                            const SizedBox(height: 16),
                            TopicInput(
                              topics: _topics,
                              onTopicsChanged: (topics) {
                                setState(() {
                                  _topics = topics;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yazılı Sınav Ayarları',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            DifficultyDropdown(
                              value: _selectedDifficulty,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedDifficulty = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Soru Sayısı: $_questionCount',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Slider(
                                    value: _questionCount.toDouble(),
                                    min: 5,
                                    max: 20,
                                    divisions: 15,
                                    label: _questionCount.toString(),
                                    activeColor: AppColors.primary,
                                    onChanged: (value) {
                                      setState(() {
                                        _questionCount = value.round();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AcademicYearInput(
                              value: _academicYear,
                              onChanged: (value) {
                                setState(() {
                                  _academicYear = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ExamPeriodDropdown(
                              value: _selectedExamPeriod,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedExamPeriod = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            DurationInput(
                              value: _duration,
                              onChanged: (value) {
                                setState(() {
                                  _duration = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Sınav Oluştur',
                      onPressed: _generateExam,
                      icon: Icons.auto_awesome,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
