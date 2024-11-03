import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_card.dart';
import 'package:teachmate_pro/core/widgets/app_dialog.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:teachmate_pro/features/student/presentation/providers/student_account_provider.dart';
import 'package:teachmate_pro/features/student/presentation/widgets/student_account_header.dart';
import 'package:teachmate_pro/features/student/presentation/widgets/student_account_info_form.dart';
import 'package:teachmate_pro/features/student/presentation/widgets/student_account_actions.dart';
import 'package:teachmate_pro/features/student/presentation/widgets/student_password_form.dart';

class StudentAccountScreen extends ConsumerStatefulWidget {
  const StudentAccountScreen({super.key});

  @override
  ConsumerState<StudentAccountScreen> createState() =>
      _StudentAccountScreenState();
}

class _StudentAccountScreenState extends ConsumerState<StudentAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _schoolNameController.text = user.schoolName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(studentAccountControllerProvider).updateAccount(
            name: _nameController.text.trim(),
            schoolName: _schoolNameController.text.trim(),
          );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        AppSnackBar.showSuccess(
          context: context,
          message: 'Hesap bilgileri güncellendi',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      AppSnackBar.showWarning(
        context: context,
        message: 'Lütfen tüm alanları doldurun',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(studentAccountControllerProvider).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
        _currentPasswordController.clear();
        _newPasswordController.clear();
        AppSnackBar.showSuccess(
          context: context,
          message: 'Şifre başarıyla güncellendi',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Hesabı Sil',
      message: 'Hesabınızı silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(studentAccountControllerProvider).deleteAccount();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ref.read(authControllerProvider).signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          Future.microtask(() => context.go('/login'));
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StudentAccountHeader(
                  name: user.name,
                  email: user.email,
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: StudentAccountInfoForm(
                            nameController: _nameController,
                            schoolNameController: _schoolNameController,
                            isEditing: _isEditing,
                            isLoading: _isLoading,
                            onEdit: () => setState(() => _isEditing = true),
                            onSave: _updateAccount,
                            formKey: _formKey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _isChangingPassword
                              ? StudentPasswordForm(
                                  currentPasswordController:
                                      _currentPasswordController,
                                  newPasswordController: _newPasswordController,
                                  isLoading: _isLoading,
                                  onSubmit: _changePassword,
                                  onCancel: () {
                                    setState(() {
                                      _isChangingPassword = false;
                                      _currentPasswordController.clear();
                                      _newPasswordController.clear();
                                    });
                                  },
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.lock_outline_rounded,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Güvenlik',
                                          style:
                                              AppTextStyles.titleLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        AppButton(
                                          text: 'Şifre Değiştir',
                                          onPressed: () => setState(
                                              () => _isChangingPassword = true),
                                          variant: AppButtonVariant.text,
                                          size: AppButtonSize.small,
                                          fullWidth: false,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Güvenliğiniz için şifrenizi düzenli olarak değiştirmenizi öneririz.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: StudentAccountActions(
                            onLogout: _handleLogout,
                            onDelete: _deleteAccount,
                            isLoading: _isLoading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            'Hata: $error',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
