import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_data.dart';

abstract class AIRepository {
  Future<String> generateLessonPlan({
    required String subject,
    required String grade,
    required String topic,
  });

  Future<String> generateExamQuestions({
    required String grade,
    required String subject,
    required List<String> topics,
    required String difficulty,
    required int questionCount,
  });

  Future<String> getTeachingTips({
    required String subject,
    required String topic,
    required String studentLevel,
  });

  Future<String> sendMessage({
    required String message,
  });

  Future<String> generateStudyRecommendations({
    required List<StudentPerformanceData> performanceData,
    required String studentName,
    required String grade,
  });
}
