import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/repositories/notification_repository.dart';
import 'package:jeevan/data/mock/mock_notification_repository.dart';
import 'package:jeevan/domain/models/notification_item.dart';

// Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});

// Future Provider for Fetching All
final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications();
});

// Derived Provider for Unread Count
final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

// AsyncNotifier for Actions
class NotificationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> markAsRead(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(id);
      ref.invalidate(notificationsProvider);
    });
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
      ref.invalidate(notificationsProvider);
    });
  }
}

final notificationControllerProvider = AsyncNotifierProvider<NotificationController, void>(() {
  return NotificationController();
});
