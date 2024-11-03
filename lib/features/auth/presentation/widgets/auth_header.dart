import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lottieUrl;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottieUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Lottie.network(
              lottieUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.school_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return child;
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: AppTextStyles.displaySmall.copyWith(
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
