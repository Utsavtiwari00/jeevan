import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/mock/mock_rover_repository.dart';
import 'package:jeevan/data/mock/mock_sensor_repository.dart';
import 'package:jeevan/data/mock/mock_chat_repository.dart';
import 'package:jeevan/data/mock/mock_notification_repository.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/chat_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mock Repositories Tests', () {
    test('MockZoneRepository gets zones and zone details', () async {
      final repo = MockZoneRepository();
      final zones = await repo.getZones();
      expect(zones.length, 4);

      final zoneA = await repo.getZone('zone-a');
      expect(zoneA.soilMoisture, 22.0);
    });

    test('MockRoverRepository gets rover state', () async {
      final repo = MockRoverRepository();
      final rover = await repo.getRover();
      expect(rover.id, 'R-01');
      expect(rover.status, RoverStatus.scanning);
      expect(rover.connection, ConnectionStatus.strong);
    });

    test('MockSensorRepository gets sensors and tanks', () async {
      final repo = MockSensorRepository();
      final sensors = await repo.getSensorData();
      expect(sensors.soilMoisture, 42.0);

      final tanks = await repo.getTankData();
      expect(tanks.pesticideLevel, 74.0);
    });

    test('MockChatRepository returns context-aware responses', () async {
      final repo = MockChatRepository();
      final response = await repo.sendMessage('Which zones need water?');
      expect(response.sender, ChatSender.assistant);
      expect(response.text.toLowerCase(), contains('zones a'));
    });

    test('MockNotificationRepository marks as read', () async {
      final repo = MockNotificationRepository();
      final list = await repo.getNotifications();
      expect(list.isNotEmpty, isTrue);

      await repo.markAllAsRead();
      final allRead = await repo.getNotifications();
      expect(allRead.every((n) => n.isRead), isTrue);
    });
  });
}

