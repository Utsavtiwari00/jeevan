import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/application/auth/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (_emailController.text.isNotEmpty) {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(_emailController.text);
      
      final authState = ref.read(authControllerProvider);
      if (!authState.hasError && mounted) {
        setState(() => _success = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: AppBar(
        backgroundColor: AppColors.paperBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoalSoil),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset your password',
                style: AppTypography.headlineMedium.copyWith(color: AppColors.charcoalSoil),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your email and we will send you a reset link',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_success)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Reset link sent to your email',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.accentGreen),
                  ),
                )
              else ...[
                if (authState.hasError)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authState.error.toString(),
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.criticalRed),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Send Reset Link',
                  onPressed: isLoading ? () {} : _handleReset,
                  isLoading: isLoading,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Back to Login',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
