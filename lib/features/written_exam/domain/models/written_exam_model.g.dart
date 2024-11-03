// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'written_exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WrittenExam _$WrittenExamFromJson(Map<String, dynamic> json) => WrittenExam(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      subject: json['subject'] as String,
      examPeriod: json['examPeriod'] as String,
      examDate: DateTime.parse(json['examDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WrittenExamToJson(WrittenExam instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'subject': instance.subject,
      'examPeriod': instance.examPeriod,
      'examDate': instance.examDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
