import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/ai/presentation/providers/ai_provider.dart';
import 'package:teachmate_pro/features/exam_creation/domain/models/exam_model.dart';

final examControllerProvider = Provider((ref) => ExamController(ref));

class ExamController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ExamController(this._ref);

  Future<List<ExamQuestion>> generateExam({
    required String grade,
    required String subject,
    required List<String> topics,
    required String difficulty,
    required int questionCount,
  }) async {
    try {
      final aiResponse =
          await _ref.read(aiControllerProvider).generateExamQuestions(
                grade: grade,
                subject: subject,
                topics: topics,
                difficulty: difficulty,
                questionCount: questionCount,
              );

      final questions = _parseAIResponseToQuestions(aiResponse);

      if (questions.isEmpty) {
        throw Exception('Soru oluşturulamadı');
      }

      if (questions.length != questionCount) {
        throw Exception('Beklenen soru sayısına ulaşılamadı');
      }

      return questions;
    } catch (e) {
      throw Exception('Sınav oluşturulurken bir hata oluştu: $e');
    }
  }

  List<ExamQuestion> _parseAIResponseToQuestions(String aiResponse) {
    final questions = <ExamQuestion>[];
    final questionBlocks = aiResponse
        .split('<SORU>')
        .where((block) => block.trim().isNotEmpty)
        .map((block) => block.split('</SORU>')[0].trim());

    for (final block in questionBlocks) {
      try {
        String questionText = '';
        final options = <String>[];
        String correctAnswer = '';

        final lines = block
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

        // Find question text (starts with a number followed by a dot)
        for (final line in lines) {
          if (RegExp(r'^\d+\.').hasMatch(line)) {
            questionText = line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
            break;
          }
        }

        // Find options (starts with A), B), C), or D))
        for (final line in lines) {
          if (RegExp(r'^[A-D]\)').hasMatch(line)) {
            final option = line.substring(2).trim();
            options.add(option);
          }
        }

        // Find correct answer (DOĞRU CEVAP: X format)
        for (final line in lines) {
          if (line.toUpperCase().contains('DOĞRU CEVAP')) {
            // Extract just the letter (A, B, C, or D) from the line
            final match = RegExp(r'[A-D](?:\)|$|\s)').firstMatch(line);
            if (match != null) {
              correctAnswer = match.group(0)!.replaceAll(RegExp(r'[\)\s]'), '');
              break;
            }
          }
        }

        // Validate and create question
        if (questionText.isNotEmpty &&
            options.length == 4 &&
            correctAnswer.isNotEmpty &&
            RegExp(r'^[A-D]$').hasMatch(correctAnswer)) {
          questions.add(ExamQuestion(
            text: questionText,
            options: options,
            correctAnswer: correctAnswer,
          ));
        }
      } catch (e) {
        print('Error parsing question: $e');
        continue;
      }
    }

    return questions;
  }

  Stream<List<ExamModel>> getTeacherExams(String teacherId) {
    return _firestore
        .collection('exams')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                  'createdAt': (doc.data()['createdAt'] as Timestamp)
                      .toDate()
                      .toIso8601String(),
                  'updatedAt': (doc.data()['updatedAt'] as Timestamp)
                      .toDate()
                      .toIso8601String(),
                }))
            .toList());
  }

  Future<void> saveExam(ExamModel exam) async {
    try {
      final examData = {
        'teacherId': exam.teacherId,
        'teacherName': exam.teacherName,
        'schoolName': exam.schoolName,
        'subject': exam.subject,
        'grade': exam.grade,
        'topics': exam.topics,
        'difficulty': exam.difficulty,
        'questions': exam.questions
            .map((q) => {
                  'text': q.text,
                  'options': q.options,
                  'correctAnswer': q.correctAnswer,
                })
            .toList(),
        'academicYear': exam.academicYear,
        'examTerm': exam.examTerm,
        'duration': exam.duration,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('exams').doc(exam.id).set(examData);
    } catch (e) {
      print('Error saving exam: $e');
      throw Exception('Sınav kaydedilirken bir hata oluştu: $e');
    }
  }

  Future<void> updateExam(ExamModel exam) async {
    try {
      final examData = {
        'teacherId': exam.teacherId,
        'teacherName': exam.teacherName,
        'schoolName': exam.schoolName,
        'subject': exam.subject,
        'grade': exam.grade,
        'topics': exam.topics,
        'difficulty': exam.difficulty,
        'questions': exam.questions
            .map((q) => {
                  'text': q.text,
                  'options': q.options,
                  'correctAnswer': q.correctAnswer,
                })
            .toList(),
        'academicYear': exam.academicYear,
        'examTerm': exam.examTerm,
        'duration': exam.duration,
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('exams').doc(exam.id).update(examData);
    } catch (e) {
      throw Exception('Sınav güncellenirken bir hata oluştu: $e');
    }
  }

  Future<void> deleteExam(String examId) async {
    try {
      await _firestore.collection('exams').doc(examId).delete();
    } catch (e) {
      throw Exception('Sınav silinirken bir hata oluştu: $e');
    }
  }
}
