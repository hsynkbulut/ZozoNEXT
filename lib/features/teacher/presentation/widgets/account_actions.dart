import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';

class AccountActions extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDelete;
  final bool isLoading;

  const AccountActions({
    super.key,
    required this.onLogout,
    required this.onDelete,
    required this.isLoading,
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
                Icons.settings_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hesap Yönetimi',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    text: 'Çıkış Yap',
                    onPressed: isLoading ? null : onLogout,
                    variant: AppButtonVariant.primary,
                    icon: Icons.logout_rounded,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Hesabı Kapat',
                    onPressed: isLoading ? null : onDelete,
                    variant: AppButtonVariant.text,
                    icon: Icons.no_accounts_outlined,
                    fullWidth: true,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Çıkış Yap',
                    onPressed: isLoading ? null : onLogout,
                    variant: AppButtonVariant.primary,
                    icon: Icons.logout_rounded,
                    size: AppButtonSize.small,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Hesabı Kapat',
                    onPressed: isLoading ? null : onDelete,
                    variant: AppButtonVariant.text,
                    icon: Icons.no_accounts_outlined,
                    size: AppButtonSize.small,
                    fullWidth: true,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
