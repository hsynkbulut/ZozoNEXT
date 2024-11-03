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
import 'package:teachmate_pro/features/quiz/domain/models/quiz_result_model.dart';
import 'package:teachmate_pro/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class QuizScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late Timer _timer;
  late int _remainingTime;
  late List<String?> _answers;
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;
  final _uuid = const Uuid();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.quiz.duration * 60;
    _answers = List.filled(widget.quiz.questions.length, null);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          _submitQuiz();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = (_remainingTime / 60).floor();
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      int correctCount = 0;
      int wrongCount = 0;

      for (int i = 0; i < widget.quiz.questions.length; i++) {
        final question = widget.quiz.questions[i];
        final answer = _answers[i];
        if (answer != null) {
          if (answer == question.correctAnswer) {
            correctCount++;
          } else {
            wrongCount++;
          }
        }
      }

      final unansweredCount =
          widget.quiz.questions.length - correctCount - wrongCount;
      final totalScore = (correctCount / widget.quiz.questions.length) * 100;

      final result = QuizResultModel(
        id: _uuid.v4(),
        quizId: widget.quiz.id,
        studentId: user.id,
        schoolName: user.schoolName,
        grade: widget.quiz.grade,
        subject: widget.quiz.subject,
        topic: widget.quiz.topic,
        correctCount: correctCount,
        wrongCount: wrongCount,
        unansweredCount: unansweredCount,
        totalScore: totalScore,
        submittedAt: DateTime.now(),
      );

      await ref.read(quizControllerProvider).submitQuizResult(result);

      if (mounted) {
        context.pushReplacement('/quiz-result', extra: result);
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
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    _timer.cancel();
    final result = await AppDialog.showConfirmation(
      context: context,
      title: 'Sınavdan Çık',
      message: 'Sınavdan çıkmak istediğinizden emin misiniz? '
          'Tüm cevaplarınız kaydedilmeyecek.',
      confirmText: 'Çık',
      cancelText: 'İptal',
      isDestructive: true,
    );
    if (!result!) {
      _startTimer();
    }
    return result;
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.quiz.questions.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(index);
                  },
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.quiz.subject,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.quiz.topic,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _remainingTime < 300
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _remainingTime < 300
                    ? AppColors.error.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _remainingTime < 300
                      ? AppColors.error
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formattedTime,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: _remainingTime < 300
                        ? AppColors.error
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Soru ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:
                    (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = widget.quiz.questions[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.text,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(question.options.length, (optionIndex) {
                final option = String.fromCharCode(65 + optionIndex);
                return _buildOptionButton(
                  option,
                  question.options[optionIndex],
                  index,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, String text, int questionIndex) {
    final isSelected = _answers[questionIndex] == option;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _answers[questionIndex] = option;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    option,
                    style: AppTextStyles.titleSmall.copyWith(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentQuestionIndex > 0)
              Expanded(
                child: AppButton(
                  text: 'Önceki Soru',
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  variant: AppButtonVariant.text,
                  icon: Icons.arrow_back_rounded,
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: _currentQuestionIndex < widget.quiz.questions.length - 1
                    ? 'Sonraki Soru'
                    : 'Sınavı Bitir',
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (_currentQuestionIndex <
                            widget.quiz.questions.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _submitQuiz();
                        }
                      },
                isLoading: _isSubmitting,
                icon: _currentQuestionIndex < widget.quiz.questions.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
