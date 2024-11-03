// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PerformanceData _$PerformanceDataFromJson(Map<String, dynamic> json) =>
    PerformanceData(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      schoolName: json['schoolName'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      grade: json['grade'] as String,
      correctCount: (json['correctCount'] as num).toInt(),
      wrongCount: (json['wrongCount'] as num).toInt(),
      unansweredCount: (json['unansweredCount'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toDouble(),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );

Map<String, dynamic> _$PerformanceDataToJson(PerformanceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'schoolName': instance.schoolName,
      'subject': instance.subject,
      'topic': instance.topic,
      'grade': instance.grade,
      'correctCount': instance.correctCount,
      'wrongCount': instance.wrongCount,
      'unansweredCount': instance.unansweredCount,
      'totalScore': instance.totalScore,
      'submittedAt': instance.submittedAt.toIso8601String(),
    };
