import 'package:jeevan/domain/models/farm.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/sensor_reading.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/rover_mission.dart';
import 'package:jeevan/domain/models/crop_scan.dart';
import 'package:jeevan/domain/models/irrigation_event.dart';
import 'package:jeevan/domain/models/notification_item.dart';
import 'package:jeevan/domain/models/app_user.dart';

class MockSeedData {
  static final Farm farm = Farm(
    id: 'farm-001',
    name: 'Green Valley Farm',
    location: 'Karnataka, India',
    areaAcres: 12.4,
    zoneCount: 4,
    roverConnected: true,
    createdAt: DateTime(2024, 1, 15),
  );

  static final List<Zone> zones = [
    Zone(
      id: 'zone-a',
      farmId: 'farm-001',
      name: 'Zone A',
      currentMoisturePercent: 22,
      moistureCategory: MoistureCategory.veryLow,
      status: ZoneStatus.irrigationRecommended,
      cropType: 'Wheat',
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
      farmId: 'farm-001',
      name: 'Zone B',
      currentMoisturePercent: 48,
      moistureCategory: MoistureCategory.medium,
      status: ZoneStatus.monitor,
      cropType: 'Rice',
      boundaryPoints: const [
        [0.48, 0.05],
        [0.92, 0.10],
        [0.95, 0.38],
        [0.52, 0.35],
      ],
    ),
    Zone(
      id: 'zone-c',
      farmId: 'farm-001',
      name: 'Zone C',
      currentMoisturePercent: 81,
      moistureCategory: MoistureCategory.high,
      status: ZoneStatus.noIrrigation,
      cropType: 'Sugarcane',
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
      farmId: 'farm-001',
      name: 'Zone D',
      currentMoisturePercent: 19,
      moistureCategory: MoistureCategory.veryLow,
      status: ZoneStatus.irrigationRecommended,
      cropType: 'Cotton',
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

  static final Map<String, SensorReading> sensorReadings = {
    'zone-a': SensorReading(
      zoneId: 'zone-a',
      soilMoisture: 22,
      soilTemperature: 26.8,
      airTemperature: 28.4,
      humidity: 54,
      rainDetected: false,
      lightIntensity: 45000,
      waterLevel: 74,
      ph: 6.5,
      ec: 1.2,
      flowRate: 0.0,
      timestamp: DateTime.now(),
    ),
    'zone-b': SensorReading(
      zoneId: 'zone-b',
      soilMoisture: 48,
      soilTemperature: 25.5,
      airTemperature: 27.2,
      humidity: 60,
      rainDetected: false,
      lightIntensity: 42000,
      waterLevel: 74,
      ph: 6.8,
      ec: 1.4,
      flowRate: 0.0,
      timestamp: DateTime.now(),
    ),
    'zone-c': SensorReading(
      zoneId: 'zone-c',
      soilMoisture: 81,
      soilTemperature: 24.8,
      airTemperature: 26.9,
      humidity: 71,
      rainDetected: true,
      lightIntensity: 28000,
      waterLevel: 74,
      ph: 7.0,
      ec: 1.6,
      flowRate: 2.1,
      timestamp: DateTime.now(),
    ),
    'zone-d': SensorReading(
      zoneId: 'zone-d',
      soilMoisture: 19,
      soilTemperature: 27.5,
      airTemperature: 29.1,
      humidity: 49,
      rainDetected: false,
      lightIntensity: 48000,
      waterLevel: 74,
      ph: 6.3,
      ec: 1.1,
      flowRate: 0.0,
      timestamp: DateTime.now(),
    ),
  };

  static final Rover rover = Rover(
    id: 'rover-01',
    batteryPercent: 78,
    latitude: 12.9716,
    longitude: 77.5946,
    status: RoverStatus.scanning,
    currentZoneId: 'zone-b',
    connectionStatus: ConnectionStatus.strong,
    lastSync: DateTime.now().subtract(const Duration(minutes: 2)),
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

  static final RoverMission activeMission = RoverMission(
    id: 'mission-001',
    name: 'Morning Field Scan',
    status: MissionStatus.running,
    startedAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 30),
    coveragePercent: 62,
    zoneSequence: ['zone-a', 'zone-b', 'zone-c', 'zone-d'],
    currentZoneId: 'zone-b',
    activityLog: [
      MissionActivityEntry(timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 30), label: 'Mission started'),
      MissionActivityEntry(timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 35), label: 'Navigating to Zone A'),
      MissionActivityEntry(timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 42), label: 'Scanning Zone A'),
      MissionActivityEntry(timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 51), label: 'Zone A scan complete'),
      MissionActivityEntry(timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 53), label: 'Navigating to Zone B'),
      MissionActivityEntry(timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 58), label: 'Scanning Zone B'),
    ],
  );

  static final List<CropScan> cropScans = [
    CropScan(
      id: 'scan-a-001',
      zoneId: 'zone-a',
      imageUrl: '',
      diagnosis: 'Possible Early Blight',
      confidencePercent: 73,
      severity: CropSeverity.moderate,
      observedInPercent: 15,
      indicators: ['Leaf discoloration', 'Brown circular lesions', 'Yellowing around spots'],
      timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15),
    ),
    CropScan(
      id: 'scan-c-001',
      zoneId: 'zone-c',
      imageUrl: '',
      diagnosis: 'Healthy - No Issues Detected',
      confidencePercent: 92,
      severity: CropSeverity.low,
      observedInPercent: 0,
      indicators: [],
      timestamp: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 45),
    ),
  ];

  static final List<IrrigationEvent> irrigationHistory = [
    IrrigationEvent(id: 'irr-1', zoneId: 'all', durationMinutes: 60, waterUsedLiters: 850, triggeredBy: TriggerType.manual, timestamp: DateTime.now().subtract(const Duration(days: 6))),
    IrrigationEvent(id: 'irr-2', zoneId: 'all', durationMinutes: 45, waterUsedLiters: 620, triggeredBy: TriggerType.automatic, timestamp: DateTime.now().subtract(const Duration(days: 5))),
    IrrigationEvent(id: 'irr-3', zoneId: 'all', durationMinutes: 0, waterUsedLiters: 0, triggeredBy: TriggerType.manual, timestamp: DateTime.now().subtract(const Duration(days: 4))),
    IrrigationEvent(id: 'irr-4', zoneId: 'all', durationMinutes: 55, waterUsedLiters: 780, triggeredBy: TriggerType.automatic, timestamp: DateTime.now().subtract(const Duration(days: 3))),
    IrrigationEvent(id: 'irr-5', zoneId: 'all', durationMinutes: 65, waterUsedLiters: 920, triggeredBy: TriggerType.manual, timestamp: DateTime.now().subtract(const Duration(days: 2))),
    IrrigationEvent(id: 'irr-6', zoneId: 'all', durationMinutes: 30, waterUsedLiters: 450, triggeredBy: TriggerType.automatic, timestamp: DateTime.now().subtract(const Duration(days: 1))),
  ];

  static const Map<String, dynamic> waterSummary = {
    'today': 0,
    'thisWeek': 3620,
    'thisMonth': 12450,
    'estimatedSavings': 2800,
  };

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

  static final AppUser user = AppUser(
    id: 'user-001',
    name: 'Utssav',
    phone: '+91 98765 43210',
    email: 'utssav@greenvalley.farm',
    farmName: 'Green Valley Farm',
    location: 'Karnataka, India',
  );
}
