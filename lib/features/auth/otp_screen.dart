import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/application/auth/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timestampr();
  }

  void _timestampr() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      await ref.read(authControllerProvider.notifier).verifyOtp(otp);
      
      final authState = ref.read(authControllerProvider);
      if (!authState.hasError && mounted) {
        context.go(RoutePaths.home);
      } else if (authState.hasError) {
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
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
                'Verify your number',
                style: AppTypography.headlineMedium.copyWith(color: AppColors.charcoalSoil),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter the 6-digit code sent to your phone',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      enabled: !isLoading,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: AppColors.surfaceWhite,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Verify',
                onPressed: isLoading ? () {} : _handleVerify,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: (_countdown == 0 && !isLoading) ? _timestampr : null,
                    child: Text(
                      _countdown > 0 ? 'Resend Code in ${_countdown}s' : 'Resend Code',
                      style: AppTypography.labelLarge.copyWith(
                        color: _countdown > 0 ? AppColors.textSecondary : AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
