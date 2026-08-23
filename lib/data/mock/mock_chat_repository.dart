import 'package:jeevan/domain/repositories/chat_repository.dart';
import 'package:jeevan/domain/models/chat_message.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockChatRepository implements ChatRepository {
  final List<ChatMessage> _messages = [];

  @override
  Future<List<ChatMessage>> getMessages() async {
    await Future.delayed(MockLatency.short);
    return _messages;
  }

  @override
  Future<ChatMessage> sendMessage(String text) async {
    await Future.delayed(MockLatency.short);
    final userMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    
    await Future.delayed(MockLatency.long);
    
    String responseText = "Farm operations are looking good. All systems running nominally.";
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('water')) {
      responseText = "Zones A and D are currently showing critically low moisture (22% and 19%) and need irrigation. Would you like me to start the irrigation cycle for these zones?";
    } else if (lowerText.contains('zone a') || lowerText.contains('dry')) {
      responseText = "Zone A is dry because its soil type has lower water retention and recent high temperatures caused rapid evaporation. Moisture is currently at 22%.";
    } else if (lowerText.contains('rover')) {
      responseText = "Rover R-01 is currently scanning Zone B. Battery is at 78% and connection is strong.";
    } else if (lowerText.contains('healthy') || lowerText.contains('crop')) {
      responseText = "Zone C scans indicate healthy crops (Sugarcane). However, Zone A shows signs of possible Early Blight with 73% confidence. Please monitor closely.";
    } else if (lowerText.contains('rain')) {
      responseText = "Rain was detected in Zone C recently, elevating moisture to 81%. Irrigation has been paused there.";
    }

    final botMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
      text: responseText,
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
    );
    _messages.add(botMsg);
    
    return botMsg;
  }

  @override
  Future<List<String>> getSuggestedPrompts() async {
    await Future.delayed(MockLatency.short);
    return MockSeedData.chatPrompts;
  }
}
