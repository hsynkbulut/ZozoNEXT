import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

class StudentProgress {
  final int completedTopics;
  final double averageScore;
  final int totalQuestions;

  const StudentProgress({
    required this.completedTopics,
    required this.averageScore,
    required this.totalQuestions,
  });

  static const empty = StudentProgress(
    completedTopics: 0,
    averageScore: 0,
    totalQuestions: 0,
  );
}

final studentProgressProvider = StreamProvider<StudentProgress>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(StudentProgress.empty);

  return FirebaseFirestore.instance
      .collection('quiz_results')
      .where('studentId', isEqualTo: user.id)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) {
      return StudentProgress.empty;
    }

    // Calculate total questions and average score
    int totalQuestions = 0;
    double totalScore = 0;
    final uniqueTopics = <String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      totalQuestions += (data['correctCount'] as int) +
          (data['wrongCount'] as int) +
          (data['unansweredCount'] as int);
      totalScore += (data['totalScore'] as num).toDouble();
      uniqueTopics.add('${data['subject']}: ${data['topic']}');
    }

    return StudentProgress(
      completedTopics: uniqueTopics.length,
      averageScore: totalScore / snapshot.docs.length,
      totalQuestions: totalQuestions,
    );
  });
});
