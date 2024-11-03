import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/features/auth/domain/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final studentsProvider = FutureProvider<List<UserModel>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
      .collection('users')
      .where('role', isEqualTo: 'student')
      .get();

  return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
});
