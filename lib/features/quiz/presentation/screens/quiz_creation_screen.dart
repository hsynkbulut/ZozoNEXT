import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:teachmate_pro/features/quiz/presentation/widgets/quiz_settings_card.dart';
import 'package:teachmate_pro/features/quiz/presentation/widgets/quiz_subject_card.dart';

class QuizCreationScreen extends ConsumerStatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  ConsumerState<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends ConsumerState<QuizCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String _selectedSubject = 'Matematik';
  String _selectedGrade = '9';
  String _selectedDifficulty = 'Orta';
  int _questionCount = 10;
  int _duration = 40;
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_topicController.text.trim().isEmpty) {
      AppSnackBar.showWarning(
        context: context,
        message: 'Lütfen bir konu girin',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final generatedQuiz = await ref.read(quizControllerProvider).generateQuiz(
            grade: _selectedGrade,
            subject: _selectedSubject,
            topic: _topicController.text.trim(),
            difficulty: _selectedDifficulty,
            questionCount: _questionCount,
            duration: _duration,
          );

      if (mounted) {
        context.push('/quiz-preview', extra: {
          'generatedQuiz': generatedQuiz,
          'examInfo': {
            'subject': _selectedSubject,
            'grade': _selectedGrade,
            'topic': _topicController.text.trim(),
            'difficulty': _selectedDifficulty,
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
        title: const Text('Quiz Oluştur'),
        actions: [
          AppButton(
            text: 'Quizlerim',
            onPressed: () => context.push('/my-quizzes'),
            variant: AppButtonVariant.primary,
            icon: Icons.folder_outlined,
            size: AppButtonSize.small,
            fullWidth: false,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                              'Quiz Bilgileri',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            QuizSubjectCard(
                              topicController: _topicController,
                              selectedSubject: _selectedSubject,
                              selectedGrade: _selectedGrade,
                              onSubjectChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSubject = value;
                                  });
                                }
                              },
                              onGradeChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGrade = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    QuizSettingsCard(
                      selectedDifficulty: _selectedDifficulty,
                      questionCount: _questionCount,
                      duration: _duration,
                      onDifficultyChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        }
                      },
                      onQuestionCountChanged: (value) {
                        setState(() {
                          _questionCount = value;
                        });
                      },
                      onDurationChanged: (value) {
                        setState(() {
                          _duration = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Quiz Oluştur',
                      onPressed: _generateQuiz,
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
