// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamModel _$ExamModelFromJson(Map<String, dynamic> json) => ExamModel(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      schoolName: json['schoolName'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as String,
      topics:
          (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => ExamQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      academicYear: json['academicYear'] as String,
      examTerm: json['examTerm'] as String,
      duration: (json['duration'] as num).toInt(),
      createdAt: ExamModel._timestampFromJson(json['createdAt']),
      updatedAt: ExamModel._timestampFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$ExamModelToJson(ExamModel instance) => <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'schoolName': instance.schoolName,
      'subject': instance.subject,
      'grade': instance.grade,
      'topics': instance.topics,
      'difficulty': instance.difficulty,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'academicYear': instance.academicYear,
      'examTerm': instance.examTerm,
      'duration': instance.duration,
      'createdAt': ExamModel._timestampToJson(instance.createdAt),
      'updatedAt': ExamModel._timestampToJson(instance.updatedAt),
    };

ExamQuestion _$ExamQuestionFromJson(Map<String, dynamic> json) => ExamQuestion(
      text: json['text'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
    );

Map<String, dynamic> _$ExamQuestionToJson(ExamQuestion instance) =>
    <String, dynamic>{
      'text': instance.text,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
    };
