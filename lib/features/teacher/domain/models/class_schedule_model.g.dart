// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassSchedule _$ClassScheduleFromJson(Map<String, dynamic> json) =>
    ClassSchedule(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as String,
      topic: json['topic'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      recurrenceRule: json['recurrenceRule'] as String,
      notes: json['notes'] as String? ?? '',
      color: json['color'] as String,
    );

Map<String, dynamic> _$ClassScheduleToJson(ClassSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'subject': instance.subject,
      'grade': instance.grade,
      'topic': instance.topic,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'recurrenceRule': instance.recurrenceRule,
      'notes': instance.notes,
      'color': instance.color,
    };
