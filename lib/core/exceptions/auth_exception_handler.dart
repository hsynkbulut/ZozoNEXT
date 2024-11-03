import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthExceptionHandler {
  static String handleException(dynamic e) {
    if (e is FirebaseAuthException) {
      return _handleFirebaseAuthException(e);
    } else if (e is FirebaseException) {
      return _handleFirebaseException(e);
    } else if (e is PlatformException) {
      return _handlePlatformException(e);
    } else if (e is FormatException) {
      return 'Geçersiz format. Lütfen girdiğiniz bilgileri kontrol edin.';
    } else {
      return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  static String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda. Lütfen başka bir e-posta adresi deneyin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi. Lütfen doğru bir e-posta adresi girin.';
      case 'operation-not-allowed':
        return 'E-posta/şifre girişi devre dışı bırakılmış. Lütfen destek ekibiyle iletişime geçin.';
      case 'weak-password':
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Lütfen destek ekibiyle iletişime geçin.';
      case 'user-not-found':
        return 'Bu e-posta adresine ait bir hesap bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre. Lütfen şifrenizi kontrol edin.';
      case 'too-many-requests':
        return 'Çok fazla başarısız giriş denemesi. Lütfen bir süre bekleyin ve tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgileri. Lütfen bilgilerinizi kontrol edin.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir giriş yöntemiyle zaten kullanımda.';
      default:
        return 'Kimlik doğrulama hatası: ${e.message}';
    }
  }

  static String _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 'unavailable':
        return 'Servis şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      case 'cancelled':
        return 'İşlem iptal edildi.';
      case 'data-loss':
        return 'Veri kaybı oluştu. Lütfen tekrar deneyin.';
      case 'deadline-exceeded':
        return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case 'already-exists':
        return 'Bu kayıt zaten mevcut.';
      case 'not-found':
        return 'İstenen kayıt bulunamadı.';
      case 'failed-precondition':
        return 'İşlem için gerekli koşullar sağlanamadı.';
      default:
        return 'Firebase hatası: ${e.message}';
    }
  }

  static String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'sign_in_failed':
        return 'Giriş başarısız oldu. Lütfen tekrar deneyin.';
      case 'network_error':
        return 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
      case 'sign_in_canceled':
        return 'Giriş işlemi iptal edildi.';
      default:
        return 'Platform hatası: ${e.message}';
    }
  }
}
