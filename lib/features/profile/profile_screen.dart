import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/widgets/layout/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _useFahrenheit = false;
  bool _irrigationAlerts = true;
  bool _healthAlerts = true;

  @override
  Widget build(BuildContext context) {
    const String userName = 'Utssav';
    const String userEmail = 'utssav@greenvalley.farm';
    const String userPhone = '+91 98765 43210';
    const String farmName = 'Green Valley Farm';
    const String farmLocation = 'Karnataka, India';
    const String farmAcreage = '12.4 acres';

    final initials = userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

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
                    backgroundColor: AppColors.accentGreen.withValues(alpha: 0.1),
                    child: Text(
                      initials,
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.accentGreen),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    userName,
                    style: AppTypography.headlineSmall.copyWith(color: AppColors.charcoalSoil),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    userEmail,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    userPhone,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Farm Info Section
            const SectionHeader(title: 'Farm Information'),
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
                  _buildInfoRow('Farm Name', farmName),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _buildInfoRow('Location', farmLocation),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _buildInfoRow('Acreage', farmAcreage),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Settings Section
            const SectionHeader(title: 'Settings'),
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
                    activeThumbColor: AppColors.accentGreen,
                    onChanged: (val) => setState(() => _useFahrenheit = val),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  SwitchListTile(
                    title: Text('Irrigation Alerts', style: AppTypography.bodyLarge),
                    value: _irrigationAlerts,
                    activeThumbColor: AppColors.accentGreen,
                    onChanged: (val) => setState(() => _irrigationAlerts = val),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  SwitchListTile(
                    title: Text('Health Alerts', style: AppTypography.bodyLarge),
                    value: _healthAlerts,
                    activeThumbColor: AppColors.accentGreen,
                    onChanged: (val) => setState(() => _healthAlerts = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Rover Info
            const SectionHeader(title: 'Equipment'),
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
