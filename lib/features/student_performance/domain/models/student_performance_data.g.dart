// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_performance_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentPerformanceData _$StudentPerformanceDataFromJson(
        Map<String, dynamic> json) =>
    StudentPerformanceData(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      grade: json['grade'] as String,
      correctCount: (json['correctCount'] as num).toInt(),
      wrongCount: (json['wrongCount'] as num).toInt(),
      unansweredCount: (json['unansweredCount'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toDouble(),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );

Map<String, dynamic> _$StudentPerformanceDataToJson(
        StudentPerformanceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quizId': instance.quizId,
      'subject': instance.subject,
      'topic': instance.topic,
      'grade': instance.grade,
      'correctCount': instance.correctCount,
      'wrongCount': instance.wrongCount,
      'unansweredCount': instance.unansweredCount,
      'totalScore': instance.totalScore,
      'submittedAt': instance.submittedAt.toIso8601String(),
    };
