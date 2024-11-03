import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teachmate_pro/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:teachmate_pro/features/auth/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachmate_pro/core/exceptions/auth_exception_handler.dart';

final authRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final userRoleProvider = StreamProvider<String?>((ref) {
  return ref.watch(currentUserProvider).when(
        data: (user) => Stream.value(user?.role),
        loading: () => Stream.value(null),
        error: (_, __) => Stream.value(null),
      );
});

final authControllerProvider = Provider((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthController(this._ref);

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String schoolName,
  }) async {
    try {
      final credential = await _ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(email, password);

      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        schoolName: schoolName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception(AuthExceptionHandler.handleException(e));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password);

      // Get user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        throw Exception('Kullanıcı bulunamadı');
      }

      final userData = userDoc.data()!;
      if (userData['role'] != role) {
        throw Exception('Geçersiz hesap türü seçildi');
      }
    } catch (e) {
      throw Exception(AuthExceptionHandler.handleException(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _ref.read(authRepositoryProvider).signOut();
    } catch (e) {
      throw Exception(AuthExceptionHandler.handleException(e));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(AuthExceptionHandler.handleException(e));
    }
  }
}
