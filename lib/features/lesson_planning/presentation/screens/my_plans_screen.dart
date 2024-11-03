import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/providers/lesson_plan_provider.dart';
import 'package:teachmate_pro/features/lesson_planning/domain/models/lesson_plan_model.dart';
import 'package:teachmate_pro/core/widgets/formatted_ai_content.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/widgets/pdf_preview_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_empty_state.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/core/widgets/app_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class MyPlansScreen extends ConsumerWidget {
  const MyPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(lessonPlansProvider);

    return Scaffold(
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
                Icons.book_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Ders Planlarım'),
          ],
        ),
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return AppEmptyState(
              icon: Icons.book_outlined,
              title: 'Henüz ders planı oluşturmadınız',
              message: 'Yeni bir ders planı oluşturmak için butona tıklayın.',
              buttonText: 'Plan Oluştur',
              onButtonPressed: () => Navigator.pop(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _PlanCard(plan: plan);
            },
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Hata: $error',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final LessonPlanModel plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.topic,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.subject} - ${plan.grade}. Sınıf',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        _showEditDialog(context, ref, plan);
                        break;
                      case 'preview':
                        showDialog(
                          context: context,
                          builder: (context) => PDFPreviewDialog(plan: plan),
                        );
                        break;
                      case 'delete':
                        await _showDeleteConfirmation(context, ref, plan);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf_outlined),
                          SizedBox(width: 8),
                          Text('PDF Görüntüle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sil',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Son Güncelleme: ${DateFormat.yMMMd().add_Hm().format(plan.updatedAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(
                    'Plan İçeriği',
                    style: AppTextStyles.titleSmall,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FormattedAIContent(content: plan.content),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    LessonPlanModel plan,
  ) async {
    final topicController = TextEditingController(text: plan.topic);
    final contentController = TextEditingController(text: plan.content);
    final screenHeight = MediaQuery.of(context).size.height;

    return AppDialog.show(
      context: context,
      title: 'Planı Düzenle',
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6, // 60% of screen height
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: topicController,
                label: 'Konu',
                hint: 'Konuyu girin',
                prefixIcon: Icons.topic_outlined,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: contentController,
                label: 'İçerik',
                hint: 'İçeriği girin',
                prefixIcon: Icons.description_outlined,
                maxLines: null, // Allow unlimited lines
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                // Set a minimum height for the content field
                minLines: 10,
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          text: 'İptal',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          fullWidth: false,
        ),
        AppButton(
          text: 'Kaydet',
          onPressed: () async {
            final updatedPlan = plan.copyWith(
              topic: topicController.text,
              content: contentController.text,
            );
            await ref
                .read(lessonPlanControllerProvider)
                .updateLessonPlan(updatedPlan);
            if (context.mounted) Navigator.of(context).pop();
          },
          fullWidth: false,
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    LessonPlanModel plan,
  ) async {
    return AppDialog.showConfirmation(
      context: context,
      title: 'Planı Sil',
      message: 'Bu ders planını silmek istediğinizden emin misiniz?',
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDestructive: true,
    ).then((confirmed) async {
      if (confirmed == true) {
        await ref.read(lessonPlanControllerProvider).deleteLessonPlan(plan.id);
      }
    });
  }
}
