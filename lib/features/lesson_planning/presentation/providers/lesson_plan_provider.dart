import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/lesson_planning/domain/models/lesson_plan_model.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

final lessonPlansProvider = StreamProvider<List<LessonPlanModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('lesson_plans')
      .where('teacherId', isEqualTo: user.id)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => LessonPlanModel.fromJson(doc.data()))
          .toList());
});

final lessonPlanControllerProvider =
    Provider((ref) => LessonPlanController(ref));

class LessonPlanController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LessonPlanController(this._ref);

  Future<void> saveLessonPlan({
    required String subject,
    required String grade,
    required String topic,
    required String content,
  }) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final planId = _firestore.collection('lesson_plans').doc().id;
    final now = DateTime.now();

    final plan = LessonPlanModel(
      id: planId,
      teacherId: user.id,
      subject: subject,
      grade: grade,
      topic: topic,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('lesson_plans').doc(planId).set(plan.toJson());
  }

  Future<void> updateLessonPlan(LessonPlanModel plan) async {
    final updatedPlan = plan.copyWith(
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('lesson_plans')
        .doc(plan.id)
        .update(updatedPlan.toJson());
  }

  Future<void> deleteLessonPlan(String planId) async {
    await _firestore.collection('lesson_plans').doc(planId).delete();
  }
}
