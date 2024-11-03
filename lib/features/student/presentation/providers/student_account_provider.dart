import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';

final studentAccountControllerProvider =
    Provider((ref) => StudentAccountController(ref));

class StudentAccountController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StudentAccountController(this._ref);

  Future<void> updateAccount({
    required String name,
    required String schoolName,
  }) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await _firestore.collection('users').doc(user.id).update({
      'name': name,
      'schoolName': schoolName,
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Mevcut şifre yanlış');
        case 'weak-password':
          throw Exception('Yeni şifre çok zayıf');
        default:
          throw Exception('Şifre güncellenirken bir hata oluştu: ${e.message}');
      }
    }
  }

  Future<void> deleteAccount() async {
    final authUser = _auth.currentUser;
    if (authUser == null) throw Exception('Kullanıcı oturumu bulunamadı');

    try {
      // Delete user data from Firestore collections
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(authUser.uid));

      // Delete written exams
      final writtenExams = await _firestore
          .collection('written_exams')
          .where('studentId', isEqualTo: authUser.uid)
          .get();
      for (final doc in writtenExams.docs) {
        batch.delete(doc.reference);
      }

      // Delete quiz results
      final quizResults = await _firestore
          .collection('quiz_results')
          .where('studentId', isEqualTo: authUser.uid)
          .get();
      for (final doc in quizResults.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Delete Firebase Auth account
      await authUser.delete();
    } catch (e) {
      throw Exception('Hesap silinirken bir hata oluştu: $e');
    }
  }
}
