import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_schedule_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ClassSchedule {
  final String id;
  final String teacherId;
  final String subject;
  final String grade;
  final String topic;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime startTime;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime endTime;

  final String recurrenceRule;
  final String notes;
  final String color;

  const ClassSchedule({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.startTime,
    required this.endTime,
    required this.recurrenceRule,
    this.notes = '',
    required this.color,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) =>
      _$ClassScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ClassScheduleToJson(this);

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

  factory ClassSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassSchedule(
      id: doc.id,
      teacherId: data['teacherId'] as String,
      subject: data['subject'] as String,
      grade: data['grade'] as String,
      topic: data['topic'] as String,
      startTime: _timestampFromJson(data['startTime']),
      endTime: _timestampFromJson(data['endTime']),
      recurrenceRule: data['recurrenceRule'] as String,
      notes: data['notes'] as String? ?? '',
      color: data['color'] as String,
    );
  }

  ClassSchedule copyWith({
    String? id,
    String? teacherId,
    String? subject,
    String? grade,
    String? topic,
    DateTime? startTime,
    DateTime? endTime,
    String? recurrenceRule,
    String? notes,
    String? color,
  }) {
    return ClassSchedule(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      topic: topic ?? this.topic,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      notes: notes ?? this.notes,
      color: color ?? this.color,
    );
  }
}

enum RecurrenceType {
  none('Tekrar Yok'),
  daily('Her Gün'),
  weekly('Her Hafta'),
  monthly('Her Ay');

  final String label;
  const RecurrenceType(this.label);
}

enum WeekDay {
  monday('Pazartesi'),
  tuesday('Salı'),
  wednesday('Çarşamba'),
  thursday('Perşembe'),
  friday('Cuma');

  final String label;
  const WeekDay(this.label);
}
