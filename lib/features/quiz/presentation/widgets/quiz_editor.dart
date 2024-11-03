import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';

class QuizEditor extends StatelessWidget {
  final List<QuizQuestion> questions;
  final ValueChanged<List<QuizQuestion>> onQuestionsUpdated;

  const QuizEditor({
    super.key,
    required this.questions,
    required this.onQuestionsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Icons.quiz_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sorular',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _QuestionItem(
              index: index,
              question: questions[index],
              onQuestionUpdated: (updatedQuestion) {
                final updatedQuestions = List<QuizQuestion>.from(questions);
                updatedQuestions[index] = updatedQuestion;
                onQuestionsUpdated(updatedQuestions);
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuestionItem extends StatefulWidget {
  final int index;
  final QuizQuestion question;
  final ValueChanged<QuizQuestion> onQuestionUpdated;

  const _QuestionItem({
    required this.index,
    required this.question,
    required this.onQuestionUpdated,
  });

  @override
  State<_QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<_QuestionItem> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late String _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(text: widget.question.text);
    _optionControllers = widget.question.options
        .map((option) => TextEditingController(text: option))
        .toList();
    _selectedAnswer = widget.question.correctAnswer;

    _questionController.addListener(_updateQuestion);
    for (var controller in _optionControllers) {
      controller.addListener(_updateQuestion);
    }
  }

  void _updateQuestion() {
    widget.onQuestionUpdated(
      QuizQuestion(
        text: _questionController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswer: _selectedAnswer,
        points: widget
            .question.points, // Include the points from the original question
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                  child: Text(
                    '${widget.index + 1}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Soru',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _questionController,
              label: 'Soru Metni',
              hint: 'Soruyu buraya yazın',
              maxLines: null,
              prefixIcon: Icons.help_outline,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _optionControllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = String.fromCharCode(65 + index);
                return Row(
                  children: [
                    Radio<String>(
                      value: option,
                      groupValue: _selectedAnswer,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAnswer = value;
                            _updateQuestion();
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: _optionControllers[index],
                        label: '$option Şıkkı',
                        hint: 'Cevabı buraya yazın',
                        prefixIcon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
