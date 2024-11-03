import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_empty_state.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';
import 'package:teachmate_pro/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  String _selectedGrade = QuizGrade.grade9.label;
  String? _selectedSubject;
  String? _selectedTopic;
  String? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sınavlar',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(140),
                  child: Container(
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedGrade,
                                items: QuizGrade.values
                                    .map((grade) => DropdownMenuItem(
                                          value: grade.label,
                                          child: Text('${grade.label}. Sınıf'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedGrade = value;
                                      _selectedTopic = null;
                                    });
                                  }
                                },
                                hint: 'Sınıf',
                                icon: Icons.school_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedSubject,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Tüm Dersler'),
                                  ),
                                  ...QuizSubject.values
                                      .map((subject) => DropdownMenuItem(
                                            value: subject.label,
                                            child: Text(subject.label),
                                          )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubject = value;
                                    _selectedTopic = null;
                                  });
                                },
                                hint: 'Ders',
                                icon: Icons.subject_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedDifficulty,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Tüm Seviyeler'),
                                  ),
                                  ...QuizDifficulty.values
                                      .map((difficulty) => DropdownMenuItem(
                                            value: difficulty.label,
                                            child: Text(difficulty.label),
                                          )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDifficulty = value;
                                  });
                                },
                                hint: 'Zorluk',
                                icon: Icons.signal_cellular_alt_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder<List<QuizModel>>(
                stream: ref.read(quizControllerProvider).getAvailableQuizzes(
                      schoolName: user.schoolName,
                      grade: _selectedGrade,
                      subject: _selectedSubject,
                      topic: _selectedTopic,
                      difficulty: _selectedDifficulty,
                    ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: AppLoadingIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Hata: ${snapshot.error}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    );
                  }

                  final quizzes = snapshot.data ?? [];

                  if (quizzes.isEmpty) {
                    return SliverFillRemaining(
                      child: AppEmptyState(
                        icon: Icons.quiz_outlined,
                        title: 'Sınav Bulunamadı',
                        message:
                            'Seçilen kriterlere uygun sınav bulunmamaktadır.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _QuizCard(quiz: quizzes[index]),
                        ),
                        childCount: quizzes.length,
                      ),
                    ),
                  );
                },
              ),
            ],
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

  Widget _buildDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        dropdownColor: Colors.white,
        style: AppTextStyles.bodyMedium,
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: () => context.push('/quiz-screen', extra: quiz),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(quiz.subject).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSubjectIcon(quiz.subject),
                      color: _getSubjectColor(quiz.subject),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${quiz.subject} - ${quiz.grade}. Sınıf',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quiz.topic,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getDifficultyColor(quiz.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      quiz.difficulty,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getDifficultyColor(quiz.difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildInfoChip(
                        icon: Icons.timer_outlined,
                        label: '${quiz.duration} dakika',
                      ),
                      _buildInfoChip(
                        icon: Icons.quiz_outlined,
                        label: '${quiz.questions.length} soru',
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'Başlat',
                    onPressed: () => context.push('/quiz-screen', extra: quiz),
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                    icon: Icons.play_arrow_rounded,
                    fullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik':
        return Icons.functions_rounded;
      case 'fizik':
        return Icons.science_rounded;
      case 'kimya':
        return Icons.science_rounded;
      case 'biyoloji':
        return Icons.biotech_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik':
        return AppColors.primary;
      case 'fizik':
        return AppColors.secondary;
      case 'kimya':
        return AppColors.success;
      case 'biyoloji':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'kolay':
        return AppColors.success;
      case 'orta':
        return AppColors.warning;
      case 'zor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
