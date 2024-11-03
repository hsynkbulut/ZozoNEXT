import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';

class PasswordChangeForm extends StatefulWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const PasswordChangeForm({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.isLoading,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<PasswordChangeForm> createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

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
          controller: widget.currentPasswordController,
          label: 'Mevcut Şifre',
          hint: 'Mevcut şifrenizi girin',
          obscureText: _obscureCurrentPassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscureCurrentPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: widget.newPasswordController,
          label: 'Yeni Şifre',
          hint: 'Yeni şifrenizi girin',
          obscureText: _obscureNewPassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              text: 'İptal',
              onPressed: widget.onCancel,
              variant: AppButtonVariant.text,
              fullWidth: false,
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Şifreyi Güncelle',
              onPressed: widget.isLoading ? null : widget.onSubmit,
              isLoading: widget.isLoading,
              fullWidth: false,
            ),
          ],
        ),
      ],
    );
  }
}
