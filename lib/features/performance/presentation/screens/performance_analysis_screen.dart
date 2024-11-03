import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/features/performance/domain/models/performance_filters.dart';
import 'package:teachmate_pro/features/performance/presentation/providers/performance_provider.dart';
import 'package:teachmate_pro/features/performance/presentation/widgets/performance_chart.dart';
import 'package:teachmate_pro/features/performance/presentation/widgets/performance_stats_card.dart';
import 'package:teachmate_pro/features/performance/presentation/widgets/subject_breakdown_card.dart';
import 'package:teachmate_pro/features/performance/presentation/widgets/topic_breakdown_card.dart';
import 'package:teachmate_pro/features/performance/presentation/widgets/student_selector.dart';

class PerformanceAnalysisScreen extends ConsumerWidget {
  const PerformanceAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(performanceFiltersProvider);
    final performanceData = ref.watch(performanceDataProvider);
    final stats = ref.watch(performanceStatsProvider);
    final availableTopics = ref.watch(availableTopicsProvider(filters.subject));

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
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Performans Analizi'),
          ],
        ),
      ),
      body: performanceData.when(
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtreler',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              StudentSelector(
                                selectedStudentId: filters.studentId,
                                onChanged: (value) {
                                  ref
                                      .read(performanceFiltersProvider.notifier)
                                      .updateStudentId(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: (constraints.maxWidth - 16) / 2,
                                        child: _buildDropdown(
                                          context: context,
                                          label: 'Ders',
                                          value: filters.subject,
                                          items: PerformanceFilters.subjects,
                                          onChanged: (value) {
                                            if (value != null) {
                                              ref
                                                  .read(
                                                      performanceFiltersProvider
                                                          .notifier)
                                                  .updateSubject(value);
                                            }
                                          },
                                          icon: Icons.book_outlined,
                                        ),
                                      ),
                                      SizedBox(
                                        width: (constraints.maxWidth - 16) / 2,
                                        child: _buildDropdown(
                                          context: context,
                                          label: 'Zaman',
                                          value: filters.timeRange,
                                          items: PerformanceFilters.timeRanges,
                                          onChanged: (value) {
                                            if (value != null) {
                                              ref
                                                  .read(
                                                      performanceFiltersProvider
                                                          .notifier)
                                                  .updateTimeRange(value);
                                            }
                                          },
                                          icon: Icons.calendar_today_outlined,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              if (filters.subject != 'Tüm Dersler') ...[
                                const SizedBox(height: 16),
                                availableTopics.when(
                                  data: (topics) => _buildDropdown(
                                    context: context,
                                    label: 'Konu',
                                    value: topics.contains(filters.topic)
                                        ? filters.topic
                                        : null,
                                    items: [
                                      'Tüm Konular',
                                      ...topics,
                                    ],
                                    onChanged: (value) {
                                      ref
                                          .read(performanceFiltersProvider
                                              .notifier)
                                          .updateTopic(value == 'Tüm Konular'
                                              ? null
                                              : value);
                                    },
                                    icon: Icons.topic_outlined,
                                  ),
                                  loading: () =>
                                      const LinearProgressIndicator(),
                                  error: (_, __) => const SizedBox(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (data.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Seçilen kriterlere uygun veri bulunamadı',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    PerformanceStatsCard(stats: stats),
                    const SizedBox(height: 16),
                    PerformanceChart(data: data),
                    const SizedBox(height: 16),
                    SubjectBreakdownCard(
                        subjectBreakdown: stats.subjectBreakdown),
                    const SizedBox(height: 16),
                    TopicBreakdownCard(
                      topicBreakdown: stats.topicBreakdown,
                      selectedSubject: filters.subject,
                    ),
                  ]),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
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
