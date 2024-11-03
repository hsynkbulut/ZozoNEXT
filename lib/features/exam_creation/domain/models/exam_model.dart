import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String schoolName;
  final String subject;
  final String grade;
  final List<String> topics;
  final String difficulty;
  final List<ExamQuestion> questions;
  final String academicYear;
  final String examTerm;
  final int duration;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  const ExamModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.schoolName,
    required this.subject,
    required this.grade,
    required this.topics,
    required this.difficulty,
    required this.questions,
    required this.academicYear,
    required this.examTerm,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamModelToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  ExamModel copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? schoolName,
    String? subject,
    String? grade,
    List<String>? topics,
    String? difficulty,
    List<ExamQuestion>? questions,
    String? academicYear,
    String? examTerm,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      schoolName: schoolName ?? this.schoolName,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      topics: topics ?? this.topics,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      academicYear: academicYear ?? this.academicYear,
      examTerm: examTerm ?? this.examTerm,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExamQuestion {
  final String text;
  final List<String> options;
  final String correctAnswer;

  const ExamQuestion({
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionToJson(this);

  ExamQuestion copyWith({
    String? text,
    List<String>? options,
    String? correctAnswer,
  }) {
    return ExamQuestion(
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }
}
