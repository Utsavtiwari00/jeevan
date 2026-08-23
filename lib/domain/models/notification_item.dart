enum NotificationCategory { irrigation, roverScan, cropHealth, rain, system }

class NotificationItem {
  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final bool isRead;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.isRead,
    required this.timestamp,
  });

  NotificationItem copyWith({
    String? id,
    NotificationCategory? category,
    String? title,
    String? body,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      category: NotificationCategory.values.firstWhere((e) => e.name == json['category']),
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'body': body,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
