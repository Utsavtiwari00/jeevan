import 'package:jeevan/domain/repositories/notification_repository.dart';
import 'package:jeevan/domain/models/notification_item.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<NotificationItem> _notifications = List.from(MockSeedData.notifications);

  @override
  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(MockLatency.medium);
    return _notifications;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(MockLatency.short);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(MockLatency.medium);
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
