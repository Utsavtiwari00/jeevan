class Formatters {
  Formatters._();

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  static String formatTemperature(double value) {
    return '${value.toStringAsFixed(1)}°C';
  }

  static String formatLiters(double value) {
    return '${value.toStringAsFixed(0)}L';
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final hours = duration.inHours;
    if (hours > 0) {
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  static String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y ago';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  static String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String greetingForTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatZoneStatus(dynamic status) {
    final s = status.toString().split('.').last;
    if (s == 'irrigationRecommended') return 'Irrigation recommended';
    if (s == 'noIrrigation') return 'No irrigation';
    if (s == 'irrigating') return 'Irrigating';
    return capitalize(s);
  }
}
