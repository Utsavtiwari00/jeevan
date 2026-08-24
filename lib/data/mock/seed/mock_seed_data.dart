import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';
import 'package:jeevan/domain/models/notification_item.dart';

class MockSeedData {
  static final List<Zone> zones = [
    Zone(
      id: 'zone-a',
      name: 'Zone A',
      soilMoisture: 22,
      rainIntensity: 0,
      temperature: 28.4,
      humidity: 54,
      disease: 'Possible Early Blight',
      diseaseConfidence: 73,
      boundaryPoints: const [
        [0.05, 0.08],
        [0.48, 0.05],
        [0.52, 0.35],
        [0.15, 0.42],
        [0.03, 0.28],
      ],
    ),
    Zone(
      id: 'zone-b',
      name: 'Zone B',
      soilMoisture: 48,
      rainIntensity: 0,
      temperature: 27.2,
      humidity: 60,
      disease: 'none',
      diseaseConfidence: 0,
      boundaryPoints: const [
        [0.48, 0.05],
        [0.92, 0.10],
        [0.95, 0.38],
        [0.52, 0.35],
      ],
    ),
    Zone(
      id: 'zone-c',
      name: 'Zone C',
      soilMoisture: 81,
      rainIntensity: 12,
      temperature: 26.9,
      humidity: 71,
      disease: 'none',
      diseaseConfidence: 0,
      boundaryPoints: const [
        [0.52, 0.35],
        [0.95, 0.38],
        [0.90, 0.78],
        [0.65, 0.92],
        [0.45, 0.70],
      ],
    ),
    Zone(
      id: 'zone-d',
      name: 'Zone D',
      soilMoisture: 19,
      rainIntensity: 0,
      temperature: 29.1,
      humidity: 49,
      disease: 'none',
      diseaseConfidence: 0,
      boundaryPoints: const [
        [0.15, 0.42],
        [0.52, 0.35],
        [0.45, 0.70],
        [0.35, 0.88],
        [0.08, 0.75],
        [0.03, 0.50],
      ],
    ),
  ];

  static final List<List<double>> fieldBoundary = [
    [0.03, 0.08],
    [0.48, 0.05],
    [0.92, 0.10],
    [0.95, 0.38],
    [0.90, 0.78],
    [0.65, 0.92],
    [0.35, 0.88],
    [0.08, 0.75],
    [0.03, 0.50],
    [0.03, 0.28]
  ];

  static final Rover rover = Rover(
    id: 'R-01',
    status: RoverStatus.scanning,
    currentZone: 'zone-b',
    connection: ConnectionStatus.strong,
  );

  static final SensorData sensorData = SensorData(
    soilMoisture: 42,
    rainIntensity: 0,
    rainStatus: 'NO RAIN',
    temperature: 28.4,
    humidity: 54,
  );

  static final TankData tankData = TankData(
    pesticideLevel: 74,
  );

  static final List<List<double>> roverPath = [
    [0.10, 0.20],
    [0.30, 0.15],
    [0.45, 0.25],
    [0.60, 0.15],
    [0.80, 0.20],
    [0.85, 0.35],
    [0.70, 0.45],
    [0.55, 0.55],
    [0.75, 0.65],
    [0.85, 0.80],
    [0.65, 0.85],
    [0.45, 0.75],
  ];

  static final List<NotificationItem> notifications = [
    NotificationItem(id: 'notif-1', title: 'Irrigation Recommended', body: 'Zone A moisture is critically low (22%).', category: NotificationCategory.irrigation, timestamp: DateTime.now().subtract(const Duration(minutes: 10)), isRead: false),
    NotificationItem(id: 'notif-2', title: 'Irrigation Recommended', body: 'Zone D moisture is critically low (19%).', category: NotificationCategory.irrigation, timestamp: DateTime.now().subtract(const Duration(minutes: 15)), isRead: false),
    NotificationItem(id: 'notif-3', title: 'Scan Complete', body: 'Zone A scan found possible Early Blight.', category: NotificationCategory.cropHealth, timestamp: DateTime.now().subtract(const Duration(hours: 1)), isRead: true),
    NotificationItem(id: 'notif-4', title: 'Rain Detected', body: 'Rain detected in Zone C. Auto-pause suggested.', category: NotificationCategory.rain, timestamp: DateTime.now().subtract(const Duration(hours: 2)), isRead: true),
    NotificationItem(id: 'notif-5', title: 'Rover Warning', body: 'Rover R-01 battery is dropping faster than usual.', category: NotificationCategory.roverScan, timestamp: DateTime.now().subtract(const Duration(hours: 3)), isRead: true),
    NotificationItem(id: 'notif-6', title: 'System Sync', body: 'System sync complete. All sensors online.', category: NotificationCategory.system, timestamp: DateTime.now().subtract(const Duration(hours: 4)), isRead: true),
    NotificationItem(id: 'notif-7', title: 'Fertilizer Reminder', body: 'Zone B is due for fertilizer application tomorrow.', category: NotificationCategory.system, timestamp: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
    NotificationItem(id: 'notif-8', title: 'Weather Alert', body: 'High temperatures expected this afternoon.', category: NotificationCategory.system, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)), isRead: true),
    NotificationItem(id: 'notif-9', title: 'Weekly Report', body: 'Your weekly farm health report is ready.', category: NotificationCategory.system, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)), isRead: true),
    NotificationItem(id: 'notif-10', title: 'Maintenance', body: 'Filter cleaning recommended for main pump.', category: NotificationCategory.system, timestamp: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
  ];

  static final List<Map<String, String>> insights = [
    {'category': 'Soil', 'text': 'Zone A is drying faster than the rest of the field', 'explanation': 'Due to recent high temperatures and lower water retention in Zone A\'s soil type, it requires more frequent irrigation compared to other zones.'},
    {'category': 'Water', 'text': 'Water usage is 18% below weekly average', 'explanation': 'Recent rainfall in Zone C allowed the automated system to pause irrigation, saving significant water resources this week.'},
    {'category': 'Crop Health', 'text': 'Possible early blight detected in Zone A', 'explanation': 'The rover scan identified leaf discoloration and brown circular lesions consistent with early blight. Early intervention is recommended to prevent spread.'},
    {'category': 'Rover', 'text': 'Rover R-01 has completed 3 full scans this week', 'explanation': 'Rover R-01 is operating efficiently, covering 100% of the field area in its last 3 missions with no navigation errors.'},
    {'category': 'Weather', 'text': 'Light rain expected tomorrow afternoon', 'explanation': 'Local forecasts indicate a 60% chance of light precipitation. Consider delaying scheduled manual irrigation for zones B and D.'},
  ];

  static final List<String> chatPrompts = [
    'Which zones need water?',
    'Why is Zone A dry?',
    'Show me rover status',
    'What crops are healthy?',
    'When did it last rain?',
  ];
}
