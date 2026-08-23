import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/application/auth/auth_provider.dart';
import 'package:jeevan/application/home/home_provider.dart';
import 'package:jeevan/widgets/buttons/secondary_button.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _useFahrenheit = false;
  bool _irrigationAlerts = true;
  bool _healthAlerts = true;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        title: Text('Logout', style: AppTypography.headlineSmall),
        content: Text('Are you sure you want to log out?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(RoutePaths.login);
              }
            },
            child: Text('Logout', style: AppTypography.labelLarge.copyWith(color: AppColors.criticalRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final farmAsync = ref.watch(farmProvider);

    if (userAsync.isLoading || farmAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.paperBackground,
        body: ProfileSkeleton(),
      );
    }

    if (userAsync.hasError || farmAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.paperBackground,
        body: ErrorState(
          message: userAsync.hasError ? userAsync.error.toString() : farmAsync.error.toString(),
          onRetry: () {
            ref.invalidate(currentUserProvider);
            ref.invalidate(farmProvider);
          },
        ),
      );
    }

    final user = userAsync.value;
    final farm = farmAsync.value;

    final initials = (user?.name ?? 'U').isNotEmpty 
        ? (user?.name ?? 'U').trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: AppBar(
        backgroundColor: AppColors.paperBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoalSoil),
        title: Text('Profile', style: AppTypography.headlineSmall.copyWith(color: AppColors.charcoalSoil)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accentGreen.withOpacity(0.1),
                    child: Text(
                      initials,
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.accentGreen),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user?.name ?? 'User',
                    style: AppTypography.headlineSmall.copyWith(color: AppColors.charcoalSoil),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  if (user?.phone != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user!.phone,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Farm Info Section
            if (farm != null) ...[
              SectionHeader(title: 'Farm Information'),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Farm Name', farm.name),
                    const Divider(color: AppColors.divider, height: AppSpacing.lg),
                    _buildInfoRow('Location', farm.location),
                    const Divider(color: AppColors.divider, height: AppSpacing.lg),
                    _buildInfoRow('Acreage', '${farm.areaAcres} acres'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Settings Section
            SectionHeader(title: 'Settings'),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Temperature Units', style: AppTypography.bodyLarge),
                    subtitle: Text(_useFahrenheit ? 'Fahrenheit (°F)' : 'Celsius (°C)', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    value: _useFahrenheit,
                    activeColor: AppColors.accentGreen,
                    onChanged: (val) => setState(() => _useFahrenheit = val),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  SwitchListTile(
                    title: Text('Irrigation Alerts', style: AppTypography.bodyLarge),
                    value: _irrigationAlerts,
                    activeColor: AppColors.accentGreen,
                    onChanged: (val) => setState(() => _irrigationAlerts = val),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  SwitchListTile(
                    title: Text('Health Alerts', style: AppTypography.bodyLarge),
                    value: _healthAlerts,
                    activeColor: AppColors.accentGreen,
                    onChanged: (val) => setState(() => _healthAlerts = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Rover Info
            SectionHeader(title: 'Equipment'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Rover Status', 'R-01 Connected'),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _buildInfoRow('Last Sync', 'Just now'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            SecondaryButton(
              label: 'Logout',
              onPressed: _handleLogout,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodyLarge.copyWith(color: AppColors.charcoalSoil)),
      ],
    );
  }
}
