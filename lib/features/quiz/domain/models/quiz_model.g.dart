// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) => QuizModel(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      schoolName: json['schoolName'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num).toInt(),
      isPublished: json['isPublished'] as bool,
      createdAt: QuizModel._timestampFromJson(json['createdAt']),
      updatedAt: QuizModel._timestampFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$QuizModelToJson(QuizModel instance) => <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'schoolName': instance.schoolName,
      'subject': instance.subject,
      'grade': instance.grade,
      'topic': instance.topic,
      'difficulty': instance.difficulty,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'duration': instance.duration,
      'isPublished': instance.isPublished,
      'createdAt': QuizModel._timestampToJson(instance.createdAt),
      'updatedAt': QuizModel._timestampToJson(instance.updatedAt),
    };

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) => QuizQuestion(
      text: json['text'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      points: (json['points'] as num).toDouble(),
    );

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'text': instance.text,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'points': instance.points,
    };
