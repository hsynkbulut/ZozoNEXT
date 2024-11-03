import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:teachmate_pro/features/teacher/domain/models/class_schedule_model.dart';
import 'package:uuid/uuid.dart';

final classSchedulesProvider = StreamProvider<List<ClassSchedule>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('class_schedules')
      .where('teacherId', isEqualTo: user.id)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ClassSchedule.fromFirestore(doc))
          .toList());
});

final classScheduleControllerProvider =
    Provider((ref) => ClassScheduleController(ref));

class ClassScheduleController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  ClassScheduleController(this._ref);

  Future<void> addSchedule(ClassSchedule schedule) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final scheduleId = _uuid.v4();
    final newSchedule = schedule.copyWith(
      id: scheduleId,
      teacherId: user.id,
    );

    await _firestore
        .collection('class_schedules')
        .doc(scheduleId)
        .set(newSchedule.toJson());
  }

  Future<void> updateSchedule(ClassSchedule schedule) async {
    await _firestore
        .collection('class_schedules')
        .doc(schedule.id)
        .update(schedule.toJson());
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore.collection('class_schedules').doc(scheduleId).delete();
  }

  Future<void> moveSchedule(
      String scheduleId, DateTime newStartTime, DateTime newEndTime) async {
    final doc =
        await _firestore.collection('class_schedules').doc(scheduleId).get();

    if (!doc.exists) throw Exception('Ders programı bulunamadı');

    final schedule = ClassSchedule.fromFirestore(doc);
    final updatedSchedule = schedule.copyWith(
      startTime: newStartTime,
      endTime: newEndTime,
    );

    await updateSchedule(updatedSchedule);
  }
}
