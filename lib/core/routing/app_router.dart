import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/features/splash/splash_screen.dart';
import 'package:jeevan/features/auth/login_screen.dart';
import 'package:jeevan/features/auth/signup_screen.dart';
import 'package:jeevan/features/auth/otp_screen.dart';
import 'package:jeevan/features/auth/forgot_password_screen.dart';
import 'package:jeevan/features/home/home_screen.dart';
import 'package:jeevan/features/field/field_map_screen.dart';
import 'package:jeevan/features/field/zone_detail_screen.dart';
import 'package:jeevan/features/crop_health/crop_analysis_screen.dart';
import 'package:jeevan/features/crop_health/scan_crop_screen.dart';
import 'package:jeevan/features/rover/rover_overview_screen.dart';
import 'package:jeevan/features/rover/rover_mission_screen.dart';
import 'package:jeevan/features/irrigation/irrigation_control_screen.dart';
import 'package:jeevan/features/irrigation/water_usage_screen.dart';
import 'package:jeevan/features/insights/insights_screen.dart';
import 'package:jeevan/features/notifications/notifications_screen.dart';
import 'package:jeevan/features/assistant/jeevan_assistant_screen.dart';
import 'package:jeevan/features/profile/profile_screen.dart';
import 'package:jeevan/widgets/connectivity/connectivity_wrapper.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _fieldNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'field');
final _roverNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rover');
final _insightsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'insights');

/// Central router configuration for Jeevan.
/// Uses StatefulShellRoute for bottom navigation tabs.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  routes: [
    // --- Auth Flow (outside shell) ---
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: RoutePaths.otp,
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // --- Main App Shell (bottom nav) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ConnectivityWrapper(
          child: _ScaffoldWithNavBar(navigationShell: navigationShell),
        );
      },
      branches: [
        // Home tab
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'irrigation',
                  builder: (context, state) => const IrrigationControlScreen(),
                ),
                GoRoute(
                  path: 'water-usage',
                  builder: (context, state) => const WaterUsageScreen(),
                ),
              ],
            ),
          ],
        ),
        // Field tab
        StatefulShellBranch(
          navigatorKey: _fieldNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.field,
              builder: (context, state) => const FieldMapScreen(),
              routes: [
                GoRoute(
                  path: 'zone/:zoneId',
                  builder: (context, state) {
                    final zoneId = state.pathParameters['zoneId']!;
                    return ZoneDetailScreen(zoneId: zoneId);
                  },
                  routes: [
                    GoRoute(
                      path: 'crop-analysis',
                      builder: (context, state) {
                        final zoneId = state.pathParameters['zoneId']!;
                        return CropAnalysisScreen(zoneId: zoneId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Rover tab
        StatefulShellBranch(
          navigatorKey: _roverNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.rover,
              builder: (context, state) => const RoverOverviewScreen(),
              routes: [
                GoRoute(
                  path: 'mission',
                  builder: (context, state) => const RoverMissionScreen(),
                ),
              ],
            ),
          ],
        ),
        // Insights tab
        StatefulShellBranch(
          navigatorKey: _insightsNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.insights,
              builder: (context, state) => const InsightsScreen(),
            ),
          ],
        ),
      ],
    ),

    // --- Full-screen routes pushed over the shell ---
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RoutePaths.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RoutePaths.assistant,
      builder: (context, state) => const JeevanAssistantScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RoutePaths.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RoutePaths.scanCrop,
      builder: (context, state) => const ScanCropScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RoutePaths.irrigation,
      builder: (context, state) => const IrrigationControlScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RoutePaths.waterUsage,
      builder: (context, state) => const WaterUsageScreen(),
    ),
  ],
);

/// Scaffold with bottom navigation bar for the main app shell.
class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.surfaceWhite,
          indicatorColor: AppColors.accentGreenLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.accentGreen),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.map_rounded, color: AppColors.accentGreen),
              label: 'Field',
            ),
            NavigationDestination(
              icon: Icon(Icons.precision_manufacturing_outlined, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.precision_manufacturing_rounded, color: AppColors.accentGreen),
              label: 'Rover',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.insights_rounded, color: AppColors.accentGreen),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
