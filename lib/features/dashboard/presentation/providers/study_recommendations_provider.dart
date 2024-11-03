import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:teachmate_pro/features/ai/presentation/providers/ai_provider.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_data.dart';

class StudyRecommendation {
  final String subject;
  final String topic;
  final String recommendation;
  final double score;

  const StudyRecommendation({
    required this.subject,
    required this.topic,
    required this.recommendation,
    required this.score,
  });

  factory StudyRecommendation.fromString(String data) {
    final parts = data.split('|');
    if (parts.length != 4)
      throw FormatException('Invalid recommendation format');

    return StudyRecommendation(
      subject: parts[0].trim(),
      topic: parts[1].trim(),
      recommendation: parts[2].trim(),
      score: double.parse(parts[3].replaceAll('%', '').trim()),
    );
  }
}

final studentPerformanceDataProvider =
    StreamProvider<List<StudentPerformanceData>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  return FirebaseFirestore.instance
      .collection('quiz_results')
      .where('studentId', isEqualTo: user.id)
      .where('submittedAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
      .orderBy('submittedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => StudentPerformanceData.fromFirestore(doc))
          .toList());
});

final studyRecommendationsProvider =
    FutureProvider<List<StudyRecommendation>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];

  final performanceDataAsync =
      await ref.watch(studentPerformanceDataProvider.future);
  if (performanceDataAsync.isEmpty) return [];

  final studentGrade =
      performanceDataAsync.isNotEmpty ? performanceDataAsync.first.grade : '9';

  try {
    final response =
        await ref.read(aiControllerProvider).generateStudyRecommendations(
              performanceData: performanceDataAsync,
              studentName: user.name,
              grade: studentGrade,
            );

    final recommendations = <StudyRecommendation>[];
    final recommendationBlock =
        RegExp(r'<RECOMMENDATIONS>(.*?)</RECOMMENDATIONS>', dotAll: true)
            .firstMatch(response)
            ?.group(1)
            ?.trim();

    if (recommendationBlock != null && recommendationBlock.isNotEmpty) {
      final lines = recommendationBlock.split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final recommendation = StudyRecommendation.fromString(line.trim());
          if (recommendation.score < 75) {
            // Only include recommendations for scores below 75%
            recommendations.add(recommendation);
          }
        } catch (e) {
          print('Error parsing recommendation: $e');
          continue;
        }
      }
    }

    return recommendations;
  } catch (e) {
    return [];
  }
});
