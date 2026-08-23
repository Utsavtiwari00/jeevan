import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/application/auth/auth_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final user = ref.read(currentUserProvider).value;
        if (user != null) {
          context.go(RoutePaths.home);
        } else {
          context.go(RoutePaths.login);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'जीवन',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.charcoalSoil,
                  fontSize: 64,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jeevan',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.charcoalSoil,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Smart agriculture, one field at a time.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
