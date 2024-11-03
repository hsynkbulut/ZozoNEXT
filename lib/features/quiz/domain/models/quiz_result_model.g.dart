// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizResultModel _$QuizResultModelFromJson(Map<String, dynamic> json) =>
    QuizResultModel(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      studentId: json['studentId'] as String,
      schoolName: json['schoolName'] as String,
      grade: json['grade'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      correctCount: (json['correctCount'] as num).toInt(),
      wrongCount: (json['wrongCount'] as num).toInt(),
      unansweredCount: (json['unansweredCount'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toDouble(),
      submittedAt: QuizResultModel._timestampFromJson(json['submittedAt']),
    );

Map<String, dynamic> _$QuizResultModelToJson(QuizResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quizId': instance.quizId,
      'studentId': instance.studentId,
      'schoolName': instance.schoolName,
      'grade': instance.grade,
      'subject': instance.subject,
      'topic': instance.topic,
      'correctCount': instance.correctCount,
      'wrongCount': instance.wrongCount,
      'unansweredCount': instance.unansweredCount,
      'totalScore': instance.totalScore,
      'submittedAt': QuizResultModel._timestampToJson(instance.submittedAt),
    };
