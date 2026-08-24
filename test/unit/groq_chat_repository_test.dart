import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jeevan/data/groq/groq_chat_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/mock/mock_rover_repository.dart';
import 'package:jeevan/data/mock/mock_sensor_repository.dart';
import 'package:jeevan/domain/models/chat_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GroqChatRepository Tests', () {
    test('returns fallback response when GROQ_API_KEY is not configured', () async {
      dotenv.testLoad(fileInput: 'GROQ_API_KEY=\n');

      final repo = GroqChatRepository(
        zoneRepository: MockZoneRepository(),
        roverRepository: MockRoverRepository(),
        sensorRepository: MockSensorRepository(),
      );

      final msg = await repo.sendMessage('Which zones need water?');
      expect(msg.sender, ChatSender.assistant);
      expect(msg.text.toLowerCase(), contains('zones a'));
    });

    test('calls Groq API endpoint with system context when key is present', () async {
      dotenv.testLoad(fileInput: 'GROQ_API_KEY=test_groq_key_12345\nGROQ_MODEL=llama-3.3-70b-versatile\n');

      Map<String, dynamic>? capturedBody;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://api.groq.com/openai/v1/chat/completions') {
          capturedHeaders = request.headers;
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'role': 'assistant',
                    'content': 'Zone A (22%) and Zone D (19%) need water immediately.',
                  }
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final repo = GroqChatRepository(
        zoneRepository: MockZoneRepository(),
        roverRepository: MockRoverRepository(),
        sensorRepository: MockSensorRepository(),
        httpClient: mockClient,
      );

      final msg = await repo.sendMessage('What zones need water?');
      expect(msg.sender, ChatSender.assistant);
      expect(msg.text, 'Zone A (22%) and Zone D (19%) need water immediately.');

      // Verify Headers
      expect(capturedHeaders?['authorization'], 'Bearer test_groq_key_12345');
      expect(capturedHeaders?['content-type'], 'application/json');

      // Verify Prompt Context in system message
      final messages = capturedBody?['messages'] as List<dynamic>;
      final systemMsg = messages.firstWhere((m) => m['role'] == 'system')['content'] as String;

      // Verify all farm context is in prompt
      expect(systemMsg, contains('Green Valley Farm'));
      expect(systemMsg, contains('R-01'));
      expect(systemMsg, contains('Zone A'));
      expect(systemMsg, contains('Possible Early Blight'));
      expect(systemMsg, contains('STRICT DOMAIN CONSTRAINT'));
      expect(systemMsg, contains('OUT-OF-BOUNDS'));
    });

    test('handles Groq API errors gracefully', () async {
      dotenv.testLoad(fileInput: 'GROQ_API_KEY=invalid_key\n');

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'message': 'Invalid API Key provided',
            }
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = GroqChatRepository(
        zoneRepository: MockZoneRepository(),
        roverRepository: MockRoverRepository(),
        sensorRepository: MockSensorRepository(),
        httpClient: mockClient,
      );

      final msg = await repo.sendMessage('Hello');
      expect(msg.sender, ChatSender.assistant);
      expect(msg.text, contains('Invalid API Key provided'));
    });
  });
}
