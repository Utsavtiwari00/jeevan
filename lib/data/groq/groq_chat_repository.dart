import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jeevan/domain/models/chat_message.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';
import 'package:jeevan/domain/repositories/chat_repository.dart';
import 'package:jeevan/domain/repositories/crop_scan_repository.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/domain/repositories/rover_repository.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

/// Chat repository integrated with Groq LLM API.
///
/// Dynamically injects live farm telemetry, Trackbot camera crop scans,
/// IoT sensor metrics, and field conditions into the system prompt.
class GroqChatRepository implements ChatRepository {
  final ZoneRepository _zoneRepository;
  final RoverRepository _roverRepository;
  final SensorRepository _sensorRepository;
  final CropScanRepository? _cropScanRepository;
  final http.Client _httpClient;

  final List<ChatMessage> _messages = [];

  GroqChatRepository({
    required ZoneRepository zoneRepository,
    required RoverRepository roverRepository,
    required SensorRepository sensorRepository,
    CropScanRepository? cropScanRepository,
    http.Client? httpClient,
  })  : _zoneRepository = zoneRepository,
        _roverRepository = roverRepository,
        _sensorRepository = sensorRepository,
        _cropScanRepository = cropScanRepository,
        _httpClient = httpClient ?? http.Client();

  @override
  Future<List<ChatMessage>> getMessages() async {
    return List.unmodifiable(_messages);
  }

  @override
  Future<List<String>> getSuggestedPrompts() async {
    return MockSeedData.chatPrompts;
  }

  /// Builds a comprehensive, real-time system prompt with live farm context,
  /// Trackbot camera scan results, and strict domain boundaries.
  Future<String> _buildSystemPrompt() async {
    List<Zone> zones;
    try {
      zones = await _zoneRepository.getZones();
    } catch (_) {
      zones = MockSeedData.zones;
    }

    Rover rover;
    try {
      rover = await _roverRepository.getRover();
    } catch (_) {
      rover = MockSeedData.rover;
    }

    SensorData sensors;
    try {
      sensors = await _sensorRepository.getSensorData();
    } catch (_) {
      sensors = MockSeedData.sensorData;
    }

    TankData tanks;
    try {
      tanks = await _sensorRepository.getTankData();
    } catch (_) {
      tanks = MockSeedData.tankData;
    }

    CropScanResult scan;
    try {
      scan = await _cropScanRepository?.getLatestScan() ??
          const CropScanResult.idle();
    } catch (_) {
      scan = const CropScanResult.idle();
    }

    final zonesTelemetry = zones.map((z) {
      final diseaseInfo = z.hasDiseaseDetected
          ? '${z.disease} (${z.diseaseConfidence.toInt()}% confidence)'
          : 'None / Healthy';
      return '• ${z.name} (ID: ${z.id}):\n'
          '  - Soil Moisture: ${z.soilMoisture.toStringAsFixed(1)}% (${z.moistureCategory.label}, Status: ${z.status.label})\n'
          '  - Temperature: ${z.temperature.toStringAsFixed(1)}°C\n'
          '  - Humidity: ${z.humidity.toStringAsFixed(1)}%\n'
          '  - Rain Intensity: ${z.rainIntensity.toStringAsFixed(1)} mm/h\n'
          '  - Crop Health: $diseaseInfo';
    }).join('\n');

    final scanTelemetry = scan.isCompleted
        ? '''
  - Status: COMPLETED
  - Crop: ${scan.formattedCrop}
  - Diagnosis: ${scan.formattedDisease}
  - Confidence: ${scan.formattedConfidence}
  - Disease Detected: ${scan.hasDisease ? "YES (Active disease detected)" : "NO (Healthy foliage)"}
  - Inference Latency: ${scan.formattedInferenceTime ?? "350 ms"}
  - Captured Snapshot: ${scan.imageUrl ?? "Available"}
  - Scanned At: ${scan.formattedTimestamp ?? "Recent"}'''
        : '''
  - Status: ${scan.status.name.toUpperCase()}
  - Details: ${scan.isProcessing ? "Currently analyzing camera frame on Trackbot" : "No recent scan"}''';

    return '''
You are Jeevan Assistant (जीवन), an elite AI precision agriculture expert for Green Valley Farm.
You are directly connected to the farm's autonomous Raspberry Pi Trackbot, IMX219 camera TFLite AI, IoT soil moisture sensors, and field irrigation controllers.

==============================
CURRENT LIVE FARM & SCAN TELEMETRY:
==============================
• Farm: Green Valley Farm (12.4 acres, Karnataka, India, Owner/Operator: Utssav)
• Trackbot Live Camera & TFLite AI Crop Scan:
$scanTelemetry
• Rover Telemetry:
  - Trackbot ID: ${rover.id}
  - Status: ${rover.status.label}
  - Current Location: ${rover.currentZone.toUpperCase()}
  - Connection Quality: ${rover.connection.label}
• Field Sensors:
  - Average Soil Moisture: ${sensors.soilMoisture.toStringAsFixed(1)}%
  - Air Temperature: ${sensors.temperature.toStringAsFixed(1)}°C
  - Ambient Humidity: ${sensors.humidity.toStringAsFixed(1)}%
  - Rain Intensity: ${sensors.rainIntensity.toStringAsFixed(1)} mm/h (${sensors.isRaining ? "Rain: ${sensors.rainStatus}" : "No Rain"})
• Tanks:
  - Pesticide / Spray Tank Level: ${tanks.pesticideLevel.toStringAsFixed(1)}%
• Active Field Zones:
$zonesTelemetry

==============================
STRUCTURED RESPONSE GUIDELINES & CONSTRAINTS:
==============================
1. STRICT DOMAIN CONSTRAINT: You ONLY answer questions regarding Green Valley Farm operations, crop health, soil moisture, rover (${rover.id}), disease mitigation, and irrigation.
2. OUT-OF-BOUNDS INQUIRIES: If the user asks questions outside farm agriculture, politely decline and state you are programmed exclusively for Green Valley Farm operations.
3. When asked about crop health, diagnosis, or diseases:
   - Provide a concise **Diagnosis Summary** with confidence score.
   - Provide **Immediate Field Action** (e.g. isolate, prune, check leaf undersides).
   - Provide **Treatment Protocol** (include both organic remedies like Neem oil/copper spray and conventional options).
   - Provide **Environmental & Irrigation Adjustments** (e.g. reduce moisture around canopy, avoid overhead watering).
4. Keep answers crisp, highly structured, well-formatted with markdown bolding and bullet points, and directly actionable.
''';
  }

  @override
  Future<ChatMessage> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    // Retrieve API key from dotenv or system environment
    String? apiKey;
    if (dotenv.isInitialized) {
      apiKey = dotenv.env['GROQ_API_KEY']?.trim();
    }
    if (apiKey == null || apiKey.isEmpty) {
      try {
        apiKey = Platform.environment['GROQ_API_KEY']?.trim();
      } catch (_) {}
    }

    var model =
        (dotenv.isInitialized ? dotenv.env['GROQ_MODEL'] : null)?.trim();
    if (model == null ||
        model.isEmpty ||
        model.contains('prompt-guard') ||
        model.contains('whisper')) {
      model = 'openai/gpt-oss-120b';
    }

    // Fallback when API key is unconfigured
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_groq_api_key_here') {
      final fallbackResponse = await _getFallbackResponse(text);
      final botMsg = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
        text: fallbackResponse,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(botMsg);
      return botMsg;
    }

    try {
      final systemPrompt = await _buildSystemPrompt();

      final List<Map<String, String>> messagesPayload = [
        {'role': 'system', 'content': systemPrompt},
      ];

      final recentHistory = _messages.length > 6
          ? _messages.sublist(_messages.length - 6)
          : _messages;

      for (final msg in recentHistory) {
        messagesPayload.add({
          'role': msg.sender == ChatSender.user ? 'user' : 'assistant',
          'content': msg.text,
        });
      }

      final response = await _httpClient
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'messages': messagesPayload,
              'temperature': 0.3,
              'max_tokens': 512,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        final responseContent = choices?.isNotEmpty == true
            ? (choices![0]['message']['content'] as String?)?.trim()
            : null;

        final botMsg = ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
          text: responseContent ?? 'No response received from assistant.',
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
        );
        _messages.add(botMsg);
        return botMsg;
      } else {
        final errorBody = response.body;
        String userFriendlyError = 'Groq API error (${response.statusCode})';
        try {
          final errJson = jsonDecode(errorBody);
          if (errJson['error']?['message'] != null) {
            userFriendlyError = 'Groq API: ${errJson['error']['message']}';
          }
        } catch (_) {}

        final botMsg = ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
          text: '$userFriendlyError\n\nPlease check your GROQ_API_KEY in .env.',
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
        );
        _messages.add(botMsg);
        return botMsg;
      }
    } catch (e) {
      final botMsg = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
        text:
            'Unable to connect to Groq LLM: $e\n\nPlease check your network connection and GROQ_API_KEY in .env.',
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(botMsg);
      return botMsg;
    }
  }

  /// Rule-based fallback when Groq API key is not configured.
  Future<String> _getFallbackResponse(String text) async {
    final lower = text.toLowerCase();
    CropScanResult scan;
    try {
      scan = await _cropScanRepository?.getLatestScan() ??
          const CropScanResult.idle();
    } catch (_) {
      scan = const CropScanResult.idle();
    }

    if (lower.contains('disease') ||
        lower.contains('crop') ||
        lower.contains('scan') ||
        lower.contains('health') ||
        lower.contains('blight')) {
      if (scan.isCompleted) {
        if (scan.hasDisease) {
          return '''### Crop Health Diagnosis: ${scan.formattedDisease} (${scan.formattedConfidence} confidence)
• **Target Crop**: ${scan.formattedCrop}
• **Status**: Active Disease Detected by Trackbot AI

### Immediate Actions:
1. **Prune Lower Foliage**: Remove severely infected lower leaves showing brown circular lesions.
2. **Apply Organic Fungicide**: Spray copper-based fungicide or Neem oil emulsion early in the morning.
3. **Adjust Irrigation**: Avoid overhead watering. Ensure drip irrigation is utilized to keep the leaf canopy dry.

*(Add your `GROQ_API_KEY` in `.env` to unlock continuous dynamic AI reasoning)*''';
        } else {
          return '''### Crop Health Diagnosis: Healthy Foliage
• **Target Crop**: ${scan.formattedCrop}
• **Status**: No disease detected (${scan.formattedConfidence} confidence)

### Agronomic Recommendation:
Maintain current soil moisture levels (40-60%) and monitor canopy progression. Next routine scan recommended in 3 days.

*(Add your `GROQ_API_KEY` in `.env` to unlock continuous dynamic AI reasoning)*''';
        }
      }
      return 'Zone A shows possible Early Blight with 73% confidence. Zones B, C, and D are currently healthy.\n\n*(Add your GROQ_API_KEY in .env for full AI reasoning)*';
    } else if (lower.contains('water') ||
        lower.contains('irrigate') ||
        lower.contains('dry')) {
      return 'Zones A (22%) and D (19%) are currently showing critically low soil moisture and require irrigation. Zone C (81%) received rain recently and does not need water.\n\n*(Add your GROQ_API_KEY in .env for full AI reasoning)*';
    } else if (lower.contains('rover') || lower.contains('status')) {
      return 'Trackbot R-01 is connected and ready. Camera stream is live on the Rover Cam tab.\n\n*(Add your GROQ_API_KEY in .env for full AI reasoning)*';
    }

    return 'Please add your `GROQ_API_KEY` in the `.env` file at the root of the project to activate live AI answers.\n\nCurrently tracking Green Valley Farm: Trackbot online, 4 zones monitored.';
  }
}
