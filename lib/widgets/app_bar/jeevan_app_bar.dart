import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// Custom app bar for the app.
class JeevanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  final bool showBackButton;
  final List<Widget> actions;
  final Color backgroundColor;

  const JeevanAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions = const [],
    this.backgroundColor = AppColors.paperBackground,
  }) : assert(title is String || title is Widget);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: AppBar(
        title: title is String
            ? Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.charcoalSoil,
                  fontWeight: FontWeight.bold,
                ),
              )
            : title,
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: showBackButton,
        iconTheme: const IconThemeData(color: AppColors.charcoalSoil),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
