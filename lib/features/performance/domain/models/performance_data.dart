import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'performance_data.g.dart';

@JsonSerializable()
class PerformanceData {
  final String id;
  final String studentId;
  final String schoolName;
  final String subject;
  final String topic;
  final String grade;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final double totalScore;
  final DateTime submittedAt;

  const PerformanceData({
    required this.id,
    required this.studentId,
    required this.schoolName,
    required this.subject,
    required this.topic,
    required this.grade,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.totalScore,
    required this.submittedAt,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDataFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceDataToJson(this);

  factory PerformanceData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerformanceData(
      id: doc.id,
      studentId: data['studentId'] as String,
      schoolName: data['schoolName'] as String,
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
