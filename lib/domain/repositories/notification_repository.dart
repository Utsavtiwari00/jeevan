import '../models/notification_item.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
