import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_performance_data.g.dart';

@JsonSerializable()
class StudentPerformanceData {
  final String id;
  final String quizId;
  final String subject;
  final String topic;
  final String grade;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final double totalScore;
  final DateTime submittedAt;

  const StudentPerformanceData({
    required this.id,
    required this.quizId,
    required this.subject,
    required this.topic,
    required this.grade,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.totalScore,
    required this.submittedAt,
  });

  factory StudentPerformanceData.fromJson(Map<String, dynamic> json) =>
      _$StudentPerformanceDataFromJson(json);

  Map<String, dynamic> toJson() => _$StudentPerformanceDataToJson(this);

  factory StudentPerformanceData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentPerformanceData(
      id: doc.id,
      quizId: data['quizId'] as String,
      subject: data['subject'] as String,
      topic: data['topic'] as String,
      grade: data['grade'] as String,
      correctCount: data['correctCount'] as int,
      wrongCount: data['wrongCount'] as int,
      unansweredCount: data['unansweredCount'] as int,
      totalScore: (data['totalScore'] as num).toDouble(),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  int get totalQuestions => correctCount + wrongCount + unansweredCount;
}
