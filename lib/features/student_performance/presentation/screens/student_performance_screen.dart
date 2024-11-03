import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dropdown.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_filters.dart';
import 'package:teachmate_pro/features/student_performance/presentation/providers/student_performance_provider.dart';
import 'package:teachmate_pro/features/student_performance/presentation/widgets/performance_summary_card.dart';
import 'package:teachmate_pro/features/student_performance/presentation/widgets/performance_trend_chart.dart';
import 'package:teachmate_pro/features/student_performance/presentation/widgets/subject_performance_card.dart';
import 'package:teachmate_pro/features/student_performance/presentation/widgets/recent_quizzes_list.dart';

class StudentPerformanceScreen extends ConsumerWidget {
  const StudentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(studentPerformanceFiltersProvider);
    final performanceData = ref.watch(studentPerformanceDataProvider);
    final availableTopics = ref.watch(studentTopicsProvider(filters.subject));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _PatternPainter(),
                      child: Container(),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Performans Analizi',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filters.timeRange,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        Row(
                          children: [
                            Expanded(
                              child: AppDropdown<String>(
                                value: filters.subject,
                                label: 'Ders',
                                items: StudentPerformanceFilters.subjects
                                    .map((subject) => DropdownMenuItem(
                                          value: subject,
                                          child: Text(subject),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(studentPerformanceFiltersProvider
                                            .notifier)
                                        .updateSubject(value);
                                  }
                                },
                                prefixIcon: Icons.book_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppDropdown<String>(
                                value: filters.timeRange,
                                label: 'Zaman',
                                items: StudentPerformanceFilters.timeRanges
                                    .map((range) => DropdownMenuItem(
                                          value: range,
                                          child: Text(range),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(studentPerformanceFiltersProvider
                                            .notifier)
                                        .updateTimeRange(value);
                                  }
                                },
                                prefixIcon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ],
                        ),
                        if (filters.subject != 'Tüm Dersler') ...[
                          const SizedBox(height: 16),
                          availableTopics.when(
                            data: (topics) => AppDropdown<String?>(
                              value: topics.contains(filters.topic)
                                  ? filters.topic
                                  : null,
                              label: 'Konu',
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Tüm Konular'),
                                ),
                                ...topics.map((topic) => DropdownMenuItem(
                                      value: topic,
                                      child: Text(topic),
                                    )),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(studentPerformanceFiltersProvider
                                        .notifier)
                                    .updateTopic(value);
                              },
                              prefixIcon: Icons.topic_outlined,
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => const SizedBox(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          performanceData.when(
            data: (data) {
              if (data.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Seçilen kriterlere uygun veri bulunamadı',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    PerformanceSummaryCard(data: data),
                    const SizedBox(height: 16),
                    PerformanceTrendChart(data: data),
                    const SizedBox(height: 16),
                    SubjectPerformanceCard(data: data),
                    const SizedBox(height: 16),
                    RecentQuizzesList(quizzes: data),
                    const SizedBox(height: 32),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Hata: $error',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    final numberOfLines = (size.width / spacing).ceil();

    for (var i = 0; i < numberOfLines; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
