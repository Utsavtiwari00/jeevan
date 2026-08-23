import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<ChatMessage> sendMessage(String text);
  Future<List<ChatMessage>> getMessages();
  Future<List<String>> getSuggestedPrompts();
}
