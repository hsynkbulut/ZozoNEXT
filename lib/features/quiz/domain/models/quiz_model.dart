import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_model.g.dart';

@JsonSerializable(explicitToJson: true)
class QuizModel {
  final String id;
  final String teacherId;
  final String schoolName;
  final String subject;
  final String grade;
  final String topic;
  final String difficulty;
  final List<QuizQuestion> questions;
  final int duration;
  final bool isPublished;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  const QuizModel({
    required this.id,
    required this.teacherId,
    required this.schoolName,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.difficulty,
    required this.questions,
    required this.duration,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizModelToJson(this);

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

  QuizModel copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? schoolName,
    String? subject,
    String? grade,
    String? topic,
    String? difficulty,
    List<QuizQuestion>? questions,
    String? academicYear,
    String? examTerm,
    int? duration,
    bool? isPublished,
    int? totalPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      schoolName: schoolName ?? this.schoolName,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      duration: duration ?? this.duration,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class QuizQuestion {
  final String text;
  final List<String> options;
  final String correctAnswer;
  final double points;

  const QuizQuestion({
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);

  QuizQuestion copyWith({
    String? text,
    List<String>? options,
    String? correctAnswer,
    double? points,
  }) {
    return QuizQuestion(
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      points: points ?? this.points,
    );
  }
}

enum QuizDifficulty {
  easy('Kolay'),
  medium('Orta'),
  hard('Zor');

  final String label;
  const QuizDifficulty(this.label);
}

enum QuizGrade {
  grade9('9'),
  grade10('10'),
  grade11('11'),
  grade12('12');

  final String label;
  const QuizGrade(this.label);
}

enum QuizSubject {
  mathematics('Matematik'),
  physics('Fizik'),
  chemistry('Kimya'),
  biology('Biyoloji'),
  literature('Edebiyat'),
  history('Tarih'),
  geography('Coğrafya');

  final String label;
  const QuizSubject(this.label);
}
