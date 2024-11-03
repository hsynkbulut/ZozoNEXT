import 'package:flutter/material.dart';
import 'package:teachmate_pro/features/exam_creation/domain/models/exam_model.dart';

class QuestionEditor extends StatelessWidget {
  final List<ExamQuestion> questions;
  final ValueChanged<List<ExamQuestion>> onQuestionsUpdated;

  const QuestionEditor({
    super.key,
    required this.questions,
    required this.onQuestionsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (context, index) {
        return _QuestionItem(
          index: index,
          question: questions[index],
          onQuestionUpdated: (updatedQuestion) {
            final updatedQuestions = List<ExamQuestion>.from(questions);
            updatedQuestions[index] = updatedQuestion;
            onQuestionsUpdated(updatedQuestions);
          },
        );
      },
    );
  }
}

class _QuestionItem extends StatefulWidget {
  final int index;
  final ExamQuestion question;
  final ValueChanged<ExamQuestion> onQuestionUpdated;

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
      ExamQuestion(
        text: _questionController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswer: _selectedAnswer,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.index + 1}. Soru',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Soru Metni',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
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
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          labelText: '$option Şıkkı',
                          border: const OutlineInputBorder(),
                        ),
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
