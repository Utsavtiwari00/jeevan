import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/application/auth/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUp(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        farmName: _farmNameController.text,
        location: _locationController.text,
      );
      
      final authState = ref.read(authControllerProvider);
      if (!authState.hasError && mounted) {
        context.go(RoutePaths.otp);
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
        title: Text('Sign Up', style: AppTypography.headlineSmall.copyWith(color: AppColors.charcoalSoil)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                _buildTextField('Full Name', _nameController, isLoading),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Phone Number', _phoneController, isLoading),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Email', _emailController, isLoading),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Password', _passwordController, isLoading, obscure: true),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Confirm Password', _confirmPasswordController, isLoading, obscure: true,
                    validator: (val) {
                      if (val != _passwordController.text) return 'Passwords do not match';
                      return val == null || val.isEmpty ? 'Required field' : null;
                    }),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Farm Name', _farmNameController, isLoading),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Location', _locationController, isLoading),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Sign Up',
                  onPressed: isLoading ? () {} : _handleSignUp,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: AppTypography.bodyMedium),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(RoutePaths.login),
                      child: Text(
                        'Login',
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

  Widget _buildTextField(String label, TextEditingController controller, bool isLoading,
      {bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      enabled: !isLoading,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surfaceWhite,
      ),
      validator: validator ?? (value) => value == null || value.isEmpty ? 'Required field' : null,
    );
  }
}
