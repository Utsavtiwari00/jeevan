import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/utils/formatters.dart';
import 'package:jeevan/application/notifications/notification_provider.dart';
import 'package:jeevan/domain/models/notification_item.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/widgets/states/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: JeevanAppBar(
        title: 'Notifications',
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationControllerProvider.notifier).markAllAsRead();
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const NotificationSkeleton(),
        error: (err, stack) => ErrorState(
          message: 'Failed to load notifications.',
          onRetry: () => ref.refresh(notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
              message: 'You\'ll see alerts about your field, rover, and crops here.',
            );
          }

          return RefreshIndicator(
            color: AppColors.accentGreen,
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                
                bool showHeader = false;
                String headerText = '';
                
                if (index == 0) {
                  showHeader = true;
                  headerText = _getDateGroup(item.timestamp);
                } else {
                  final previousItem = notifications[index - 1];
                  final currentGroup = _getDateGroup(item.timestamp);
                  final previousGroup = _getDateGroup(previousItem.timestamp);
                  if (currentGroup != previousGroup) {
                    showHeader = true;
                    headerText = currentGroup;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                        child: Text(
                          headerText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    _NotificationTile(item: item),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);
    
    if (itemDate == today) return 'Today';
    if (itemDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return 'Earlier';
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        if (!item.isRead) {
          ref.read(notificationControllerProvider.notifier).markAsRead(item.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surfaceWhite : AppColors.accentGreenLight,
          border: const Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: _getCategoryColor(item.category),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.charcoalSoil,
                      fontSize: 16,
                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.body,
                    style: TextStyle(
                      color: item.isRead ? AppColors.textSecondary : AppColors.charcoalSoil,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    Formatters.formatTimeAgo(item.timestamp),
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.irrigation: return Icons.water_drop;
      case NotificationCategory.roverScan: return Icons.radar;
      case NotificationCategory.cropHealth: return Icons.eco;
      case NotificationCategory.rain: return Icons.cloud;
      case NotificationCategory.system: return Icons.settings;
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.irrigation: return AppColors.waterBlue;
      case NotificationCategory.roverScan: return AppColors.charcoalSoil;
      case NotificationCategory.cropHealth: return AppColors.accentGreen;
      case NotificationCategory.rain: return AppColors.waterBlue;
      case NotificationCategory.system: return AppColors.textSecondary;
    }
  }
}
