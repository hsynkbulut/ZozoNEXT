import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_result_model.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:teachmate_pro/features/ai/presentation/providers/ai_provider.dart';
import 'package:uuid/uuid.dart';

final quizControllerProvider = Provider((ref) => QuizController(ref));

class QuizController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  QuizController(this._ref);

  Stream<List<QuizModel>> getAvailableQuizzes({
    required String schoolName,
    required String grade,
    String? subject,
    String? topic,
    String? difficulty,
  }) {
    Query query = _firestore
        .collection('quizzes')
        .where('schoolName', isEqualTo: schoolName)
        .where('grade', isEqualTo: grade)
        .where('isPublished', isEqualTo: true);

    if (subject != null) {
      query = query.where('subject', isEqualTo: subject);
    }
    if (topic != null) {
      query = query.where('topics', arrayContains: topic);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    return query.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map(
                (doc) => QuizModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<QuizModel>> getTeacherQuizzes(String teacherId) {
    return _firestore
        .collection('quizzes')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => QuizModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<QuizModel> generateQuiz({
    required String grade,
    required String subject,
    required String topic,
    required String difficulty,
    required int questionCount,
    required int duration,
  }) async {
    try {
      final user = _ref.read(currentUserProvider).value;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final aiResponse =
          await _ref.read(aiControllerProvider).generateExamQuestions(
                grade: grade,
                subject: subject,
                topics: [topic],
                difficulty: difficulty,
                questionCount: questionCount,
              );

      final questions = _parseAIResponseToQuestions(aiResponse);
      if (questions.isEmpty) {
        throw Exception('Soru oluşturulamadı');
      }

      final quizId = const Uuid().v4();
      final now = DateTime.now();

      return QuizModel(
        id: quizId,
        teacherId: user.id,
        schoolName: user.schoolName,
        subject: subject,
        grade: grade,
        topic: topic,
        difficulty: difficulty,
        questions: questions,
        duration: duration,
        isPublished: false,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Quiz oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<void> saveQuiz(QuizModel quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).update(quiz.toJson());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

  Future<void> submitQuizResult(QuizResultModel result) async {
    await _firestore
        .collection('quiz_results')
        .doc(result.id)
        .set(result.toJson());
  }

  List<QuizQuestion> _parseAIResponseToQuestions(String aiResponse) {
    final questions = <QuizQuestion>[];
    final sections = aiResponse
        .split('<SORU>')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();

    for (final section in sections) {
      try {
        // Extract question text
        final questionMatch =
            RegExp(r'^\d+\.\s*(.+?)(?=\n[A-D]\))', dotAll: true)
                .firstMatch(section);
        if (questionMatch == null) continue;
        final questionText = questionMatch.group(1)?.trim() ?? '';

        // Extract options
        final options = <String>[];
        final optionMatches =
            RegExp(r'([A-D]\))\s*([^\n]+)').allMatches(section).toList();

        if (optionMatches.length != 4) continue;

        // Create a map of option letter to option text
        final optionMap = <String, String>{};
        for (final match in optionMatches) {
          final letter = match.group(1)?.replaceAll(')', '') ?? '';
          final text = match.group(2)?.trim() ?? '';
          optionMap[letter] = text;
        }

        // Extract correct answer
        final correctAnswerMatch =
            RegExp(r'DOĞRU CEVAP:\s*([A-D])').firstMatch(section);
        if (correctAnswerMatch == null) continue;
        final correctAnswer = correctAnswerMatch.group(1) ?? '';

        // Verify we have all required components
        if (questionText.isEmpty ||
            optionMap.length != 4 ||
            correctAnswer.isEmpty ||
            !RegExp(r'^[A-D]$').hasMatch(correctAnswer)) {
          continue;
        }

        // Create ordered list of options based on the original order (A, B, C, D)
        final orderedOptions = ['A', 'B', 'C', 'D']
            .map((letter) => optionMap[letter] ?? '')
            .toList();

        questions.add(QuizQuestion(
          text: questionText,
          options: orderedOptions,
          correctAnswer: correctAnswer,
          points: 0,
        ));
      } catch (e) {
        print('Error parsing question: $e');
        continue;
      }
    }

    return questions;
  }
}
