import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/data/mock/mock_farm_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/mock/mock_rover_repository.dart';
import 'package:jeevan/data/mock/mock_auth_repository.dart';
import 'package:jeevan/data/mock/mock_chat_repository.dart';
import 'package:jeevan/data/mock/mock_notification_repository.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/chat_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mock Repositories Tests', () {
    test('MockFarmRepository returns farm data', () async {
      final repo = MockFarmRepository();
      final farm = await repo.getFarm('farm-001');
      expect(farm.name, 'Green Valley Farm');
      expect(farm.areaAcres, 12.4);
    });

    test('MockZoneRepository gets zones and triggers irrigation with state mutation', () async {
      final repo = MockZoneRepository();
      final zones = await repo.getZones('farm-001');
      expect(zones.length, 4);

      final zoneA = await repo.getZone('zone-a');
      expect(zoneA.currentMoisturePercent, 22.0);

      // Trigger irrigation on Zone A
      await repo.triggerIrrigation('zone-a', durationMinutes: 15);
      final updatedZoneA = await repo.getZone('zone-a');
      expect(updatedZoneA.currentMoisturePercent, greaterThan(22.0));
    });

    test('MockRoverRepository controls rover state', () async {
      final repo = MockRoverRepository();
      final rover = await repo.getRover('rover-01');
      expect(rover.status, RoverStatus.scanning);

      await repo.pauseScan('rover-01');
      final paused = await repo.getRover('rover-01');
      expect(paused.status, RoverStatus.paused);

      await repo.resumeScan('rover-01');
      final resumed = await repo.getRover('rover-01');
      expect(resumed.status, RoverStatus.scanning);
    });

    test('MockAuthRepository login and OTP verification', () async {
      final repo = MockAuthRepository();
      final user = await repo.login('test@farm.com', 'password123');
      expect(user.name, 'Utssav');

      final otpValid = await repo.verifyOtp('123456');
      expect(otpValid, isTrue);

      final otpInvalid = await repo.verifyOtp('000000');
      expect(otpInvalid, isFalse);
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
