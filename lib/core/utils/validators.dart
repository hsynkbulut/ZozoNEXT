class Validators {
  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.isEmpty) {
        return '$fieldName zorunludur';
      }
      return null;
    };
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta zorunludur';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre zorunludur';
    }

    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermelidir';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermelidir';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Şifre en az bir özel karakter içermelidir';
    }

    return null;
  }
}
