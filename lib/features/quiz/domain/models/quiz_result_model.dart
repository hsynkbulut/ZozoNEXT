import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_result_model.g.dart';

@JsonSerializable()
class QuizResultModel {
  final String id;
  final String quizId;
  final String studentId;
  final String schoolName;
  final String grade;
  final String subject;
  final String topic;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final double totalScore;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime submittedAt;

  const QuizResultModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.schoolName,
    required this.grade,
    required this.subject,
    required this.topic,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.totalScore,
    required this.submittedAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuizResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizResultModelToJson(this);

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
    return Timestamp.fromDate(dateTime);
  }
}
