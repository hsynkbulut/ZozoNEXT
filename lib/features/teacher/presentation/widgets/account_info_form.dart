import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';

class AccountInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController schoolNameController;
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final GlobalKey<FormState> formKey;

  const AccountInfoForm({
    super.key,
    required this.nameController,
    required this.schoolNameController,
    required this.isEditing,
    required this.isLoading,
    required this.onEdit,
    required this.onSave,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
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
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hesap Bilgileri',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isEditing)
                AppButton(
                  text: 'Kaydet',
                  onPressed: isLoading ? null : onSave,
                  isLoading: isLoading,
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.small,
                  fullWidth: false,
                )
              else
                AppButton(
                  text: 'Düzenle',
                  onPressed: onEdit,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  fullWidth: false,
                ),
            ],
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: nameController,
            label: 'Ad Soyad',
            hint: 'Adınızı ve soyadınızı girin',
            enabled: isEditing,
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ad Soyad zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: schoolNameController,
            label: 'Okul Adı',
            hint: 'Okulunuzun adını girin',
            enabled: isEditing,
            prefixIcon: Icons.business_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Okul adı zorunludur';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
