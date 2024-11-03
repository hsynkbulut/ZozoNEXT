import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/features/ai/data/repositories/gemini_repository.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_data.dart';

final aiRepositoryProvider = Provider((ref) => GeminiRepository());

final aiControllerProvider = Provider((ref) => AIController(ref));

class AIController {
  final Ref _ref;

  AIController(this._ref);

  Future<String> generateLessonPlan({
    required String subject,
    required String grade,
    required String topic,
  }) async {
    try {
      return await _ref.read(aiRepositoryProvider).generateLessonPlan(
            subject: subject,
            grade: grade,
            topic: topic,
          );
    } catch (e) {
      throw Exception('Ders planı oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<String> generateExamQuestions({
    required String grade,
    required String subject,
    required List<String> topics,
    required String difficulty,
    required int questionCount,
  }) async {
    try {
      return await _ref.read(aiRepositoryProvider).generateExamQuestions(
            grade: grade,
            subject: subject,
            topics: topics,
            difficulty: difficulty,
            questionCount: questionCount,
          );
    } catch (e) {
      throw Exception('Sınav soruları oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<String> getTeachingTips({
    required String subject,
    required String topic,
    required String studentLevel,
  }) async {
    try {
      return await _ref.read(aiRepositoryProvider).getTeachingTips(
            subject: subject,
            topic: topic,
            studentLevel: studentLevel,
          );
    } catch (e) {
      throw Exception('Öğretim önerileri oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<String> sendMessage({
    required String message,
  }) async {
    try {
      return await _ref.read(aiRepositoryProvider).sendMessage(
            message: message,
          );
    } catch (e) {
      throw Exception('Mesaj gönderilemedi: $e');
    }
  }

  Future<String> generateStudyRecommendations({
    required List<StudentPerformanceData> performanceData,
    required String studentName,
    required String grade,
  }) async {
    try {
      return await _ref.read(aiRepositoryProvider).generateStudyRecommendations(
            performanceData: performanceData,
            studentName: studentName,
            grade: grade,
          );
    } catch (e) {
      throw Exception('Çalışma önerileri oluşturulamadı: $e');
    }
  }
}
