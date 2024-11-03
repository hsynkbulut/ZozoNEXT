import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/features/dashboard/presentation/widgets/dashboard_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      padding: EdgeInsets.zero,
      children: [
        DashboardCard(
          title: 'Ders Planı\nOluştur',
          icon: Icons.book_outlined,
          color: AppColors.primary,
          onTap: () => context.push('/lesson-plan'),
        ),
        DashboardCard(
          title: 'Yazılı Sınav\nHazırla',
          icon: Icons.quiz_outlined,
          color: AppColors.secondary,
          onTap: () => context.push('/exam-creation'),
        ),
        DashboardCard(
          title: 'Quiz\nOluştur',
          icon: Icons.assignment_outlined,
          color: AppColors.accent,
          onTap: () => context.push('/quiz-creation'),
        ),
        DashboardCard(
          title: 'Quizlerim',
          icon: Icons.folder_outlined,
          color: AppColors.success,
          onTap: () => context.push('/my-quizzes'),
        ),
        DashboardCard(
          title: 'Performans\nAnalizi',
          icon: Icons.analytics_outlined,
          color: AppColors.warning,
          onTap: () => context.push('/performance'),
        ),
        DashboardCard(
          title: 'Ders\nProgramı',
          icon: Icons.calendar_today_outlined,
          color: AppColors.error,
          onTap: () => context.push('/class-schedule'),
        ),
      ],
    );
  }
}
