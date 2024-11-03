import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'written_exam_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WrittenExam {
  final String id;
  final String studentId;
  final String subject;
  final String examPeriod;
  final DateTime examDate;
  final DateTime createdAt;

  const WrittenExam({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.examPeriod,
    required this.examDate,
    required this.createdAt,
  });

  factory WrittenExam.fromJson(Map<String, dynamic> json) =>
      _$WrittenExamFromJson(json);

  Map<String, dynamic> toJson() => _$WrittenExamToJson(this);

  factory WrittenExam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WrittenExam(
      id: doc.id,
      studentId: data['studentId'] as String,
      subject: data['subject'] as String,
      examPeriod: data['examPeriod'] as String,
      examDate: DateTime.parse(data['examDate'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  static const examPeriods = [
    '1. Dönem 1. Yazılı',
    '1. Dönem 2. Yazılı',
    '1. Dönem 3. Yazılı',
    '2. Dönem 1. Yazılı',
    '2. Dönem 2. Yazılı',
    '2. Dönem 3. Yazılı',
  ];

  static const subjects = [
    'Matematik',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Tarih',
    'Coğrafya',
  ];
}
