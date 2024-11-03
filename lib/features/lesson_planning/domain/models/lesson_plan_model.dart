import 'package:json_annotation/json_annotation.dart';

part 'lesson_plan_model.g.dart';

@JsonSerializable()
class LessonPlanModel {
  final String id;
  final String teacherId;
  final String subject;
  final String grade;
  final String topic;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonPlanModel({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonPlanModel.fromJson(Map<String, dynamic> json) =>
      _$LessonPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonPlanModelToJson(this);

  LessonPlanModel copyWith({
    String? id,
    String? teacherId,
    String? subject,
    String? grade,
    String? topic,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonPlanModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      topic: topic ?? this.topic,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
