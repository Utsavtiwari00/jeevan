import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/widgets/buttons/secondary_button.dart';
import 'package:jeevan/application/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
      
      final authState = ref.read(authControllerProvider);
      if (!authState.hasError && mounted) {
        context.go(RoutePaths.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Text(
                    'Jeevan',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.charcoalSoil,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
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
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.accentGreen,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                        ),
                        Text('Remember me', style: AppTypography.bodyMedium),
                      ],
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.push(RoutePaths.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.accentGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Login',
                  onPressed: isLoading ? () {} : _handleLogin,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: 'Continue with Phone',
                  onPressed: isLoading ? () {} : () {},
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?', style: AppTypography.bodyMedium),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.push(RoutePaths.signup),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.accentGreen),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
