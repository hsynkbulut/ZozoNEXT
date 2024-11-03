import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';

class StudentPasswordForm extends StatelessWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const StudentPasswordForm({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.isLoading,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Şifre Değiştir',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: currentPasswordController,
          label: 'Mevcut Şifre',
          hint: 'Mevcut şifrenizi girin',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: newPasswordController,
          label: 'Yeni Şifre',
          hint: 'Yeni şifrenizi girin',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              text: 'İptal',
              onPressed: onCancel,
              variant: AppButtonVariant.text,
              fullWidth: false,
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Şifreyi Güncelle',
              onPressed: isLoading ? null : onSubmit,
              isLoading: isLoading,
              fullWidth: false,
            ),
          ],
        ),
      ],
    );
  }
}
