import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/written_exam/domain/models/written_exam_model.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

final writtenExamsProvider = StreamProvider<List<WrittenExam>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('written_exams')
      .where('studentId', isEqualTo: user.id)
      .orderBy('examDate')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => WrittenExam.fromFirestore(doc)).toList());
});

final nextWrittenExamsProvider = StreamProvider<List<WrittenExam>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  // Get current date at start of day
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day).toIso8601String();

  // Get date 5 days from now at end of day
  final fiveDaysLater = DateTime(
    now.year,
    now.month,
    now.day + 5,
    23,
    59,
    59,
  ).toIso8601String();

  return FirebaseFirestore.instance
      .collection('written_exams')
      .where('studentId', isEqualTo: user.id)
      .where('examDate', isGreaterThanOrEqualTo: today)
      .where('examDate', isLessThanOrEqualTo: fiveDaysLater)
      .orderBy('examDate')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => WrittenExam.fromFirestore(doc)).toList());
});

final writtenExamControllerProvider =
    Provider((ref) => WrittenExamController(ref));

class WrittenExamController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WrittenExamController(this._ref);

  Future<void> addExam({
    required String subject,
    required String examPeriod,
    required DateTime examDate,
  }) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) throw Exception('User not authenticated');

    // Set the exam time to start of day and convert to ISO string
    final normalizedDate = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
    ).toIso8601String();

    final examId = _firestore.collection('written_exams').doc().id;
    final now = DateTime.now().toIso8601String();

    final examData = {
      'id': examId,
      'studentId': user.id,
      'subject': subject,
      'examPeriod': examPeriod,
      'examDate': normalizedDate,
      'createdAt': now,
    };

    await _firestore.collection('written_exams').doc(examId).set(examData);
  }

  Future<void> updateExam({
    required String examId,
    required String subject,
    required String examPeriod,
    required DateTime examDate,
  }) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) throw Exception('User not authenticated');

    // Set the exam time to start of day and convert to ISO string
    final normalizedDate = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
    ).toIso8601String();

    final examData = {
      'id': examId,
      'studentId': user.id,
      'subject': subject,
      'examPeriod': examPeriod,
      'examDate': normalizedDate,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _firestore.collection('written_exams').doc(examId).update(examData);
  }

  Future<void> deleteExam(String examId) async {
    await _firestore.collection('written_exams').doc(examId).delete();
  }
}
