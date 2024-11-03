import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_data.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_filters.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

final studentPerformanceFiltersProvider = StateNotifierProvider<
    StudentPerformanceFiltersNotifier, StudentPerformanceFilters>((ref) {
  return StudentPerformanceFiltersNotifier();
});

class StudentPerformanceFiltersNotifier
    extends StateNotifier<StudentPerformanceFilters> {
  StudentPerformanceFiltersNotifier()
      : super(const StudentPerformanceFilters(
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
}

final studentTopicsProvider =
    StreamProvider.family<List<String>, String>((ref, subject) {
  if (subject == 'Tüm Dersler') return Stream.value([]);

  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('quiz_results')
      .where('studentId', isEqualTo: user.id)
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

final studentPerformanceDataProvider =
    StreamProvider<List<StudentPerformanceData>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final filters = ref.watch(studentPerformanceFiltersProvider);

  Query query = FirebaseFirestore.instance
      .collection('quiz_results')
      .where('studentId', isEqualTo: user.id);

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

  return query.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => StudentPerformanceData.fromFirestore(doc))
      .toList());
});
