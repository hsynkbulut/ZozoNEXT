import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/performance/domain/models/performance_data.dart';
import 'package:teachmate_pro/features/performance/domain/models/performance_stats.dart';
import 'package:teachmate_pro/features/performance/domain/models/performance_filters.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

final performanceFiltersProvider =
    StateNotifierProvider<PerformanceFiltersNotifier, PerformanceFilters>(
        (ref) {
  return PerformanceFiltersNotifier();
});

class PerformanceFiltersNotifier extends StateNotifier<PerformanceFilters> {
  PerformanceFiltersNotifier()
      : super(const PerformanceFilters(
          subject: 'Tüm Dersler',
          timeRange: 'Son 30 Gün',
        ));

  void updateSubject(String subject) {
    state = state.copyWith(subject: subject, topic: null);
  }

  void updateTopic(String? topic) {
    state = state.copyWith(topic: topic);
  }

  void updateTimeRange(String timeRange) {
    state = state.copyWith(timeRange: timeRange);
  }

  void updateStudentId(String? studentId) {
    state = state.copyWith(studentId: studentId);
  }
}

final availableTopicsProvider =
    StreamProvider.family<List<String>, String>((ref, subject) {
  if (subject == 'Tüm Dersler') return Stream.value([]);

  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('quiz_results')
      .where('schoolName', isEqualTo: user.schoolName)
      .where('subject', isEqualTo: subject)
      .snapshots()
      .map((snapshot) {
    final topics = snapshot.docs
        .map((doc) => doc.data()['topic'] as String)
        .toSet()
        .toList();
    topics.sort();
    return topics;
  });
});

final performanceDataProvider = StreamProvider<List<PerformanceData>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final filters = ref.watch(performanceFiltersProvider);

  Query query = FirebaseFirestore.instance
      .collection('quiz_results')
      .where('schoolName', isEqualTo: user.schoolName);

  if (filters.studentId != null) {
    query = query.where('studentId', isEqualTo: filters.studentId);
  }

  if (filters.subject != 'Tüm Dersler') {
    query = query.where('subject', isEqualTo: filters.subject);
    if (filters.topic != null) {
      query = query.where('topic', isEqualTo: filters.topic);
    }
  }

  DateTime startDate;
  switch (filters.timeRange) {
    case 'Son 7 Gün':
      startDate = DateTime.now().subtract(const Duration(days: 7));
      break;
    case 'Son 3 Ay':
      startDate = DateTime.now().subtract(const Duration(days: 90));
      break;
    case 'Son 30 Gün':
    default:
      startDate = DateTime.now().subtract(const Duration(days: 30));
  }

  query = query
      .where('submittedAt', isGreaterThanOrEqualTo: startDate)
      .orderBy('submittedAt', descending: true);

  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => PerformanceData.fromFirestore(doc)).toList());
});

final performanceStatsProvider = Provider<PerformanceStats>((ref) {
  final dataAsync = ref.watch(performanceDataProvider);

  return dataAsync.when(
    data: (data) {
      if (data.isEmpty) return PerformanceStats.empty();

      final totalQuestions = data.fold<int>(
        0,
        (sum, item) => sum + item.totalQuestions,
      );

      final totalCorrect = data.fold<int>(
        0,
        (sum, item) => sum + item.correctCount,
      );

      final totalIncorrect = data.fold<int>(
        0,
        (sum, item) => sum + item.wrongCount,
      );

      final averageScore = data.fold<double>(
            0,
            (sum, item) => sum + item.totalScore,
          ) /
          data.length;

      // Calculate subject breakdown
      final subjectBreakdown = <String, List<double>>{};
      for (final item in data) {
        subjectBreakdown
            .putIfAbsent(item.subject, () => [])
            .add(item.totalScore);
      }
      final subjectAverages = Map<String, double>.fromEntries(
        subjectBreakdown.entries.map(
          (e) => MapEntry(
            e.key,
            e.value.reduce((a, b) => a + b) / e.value.length,
          ),
        ),
      );

      // Calculate topic breakdown
      final topicBreakdown = <String, List<double>>{};
      for (final item in data) {
        final key = '${item.subject}: ${item.topic}';
        topicBreakdown.putIfAbsent(key, () => []).add(item.totalScore);
      }
      final topicAverages = Map<String, double>.fromEntries(
        topicBreakdown.entries.map(
          (e) => MapEntry(
            e.key,
            e.value.reduce((a, b) => a + b) / e.value.length,
          ),
        ),
      );

      return PerformanceStats(
        averageScore: averageScore,
        totalQuestions: totalQuestions,
        totalCorrect: totalCorrect,
        totalIncorrect: totalIncorrect,
        subjectBreakdown: subjectAverages,
        topicBreakdown: topicAverages,
      );
    },
    loading: () => PerformanceStats.empty(),
    error: (_, __) => PerformanceStats.empty(),
  );
});
