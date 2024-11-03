// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonPlanModel _$LessonPlanModelFromJson(Map<String, dynamic> json) =>
    LessonPlanModel(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as String,
      topic: json['topic'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LessonPlanModelToJson(LessonPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'subject': instance.subject,
      'grade': instance.grade,
      'topic': instance.topic,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
