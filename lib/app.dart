import 'package:flutter/material.dart';
import 'package:jeevan/core/routing/app_router.dart';
import 'package:jeevan/core/theme/app_theme.dart';

/// Root application widget for Jeevan.
/// 
/// Configures MaterialApp.router with the app theme and go_router,
/// wrapped in a ProviderScope for Riverpod state management.
class JeevanApp extends StatelessWidget {
  const JeevanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jeevan — जीवन',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
