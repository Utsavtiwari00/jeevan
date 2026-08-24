import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/repositories/chat_repository.dart';
import 'package:jeevan/data/groq/groq_chat_repository.dart';
import 'package:jeevan/domain/models/chat_message.dart';
import 'package:jeevan/application/field/field_provider.dart';
import 'package:jeevan/application/rover/rover_provider.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';

// Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final zoneRepo = ref.watch(zoneRepositoryProvider);
  final roverRepo = ref.watch(roverRepositoryProvider);
  final sensorRepo = ref.watch(sensorRepositoryProvider);
  final cropScanRepo = ref.watch(cropScanRepositoryProvider);
  return GroqChatRepository(
    zoneRepository: zoneRepo,
    roverRepository: roverRepo,
    sensorRepository: sensorRepo,
    cropScanRepository: cropScanRepo,
  );
});

// Messages Provider
final chatMessagesProvider = FutureProvider<List<ChatMessage>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessages();
});

// Suggested Prompts Provider
final suggestedPromptsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getSuggestedPrompts();
});

// Controller for Actions
class ChatController extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() {
    // state represents 'isSending'
    return false;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = const AsyncValue.data(true); // Sending started
    
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.sendMessage(text);
      ref.invalidate(chatMessagesProvider);
      ref.invalidate(suggestedPromptsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      state = const AsyncValue.data(false); // Sending finished
    }
  }
}

final chatControllerProvider = AsyncNotifierProvider<ChatController, bool>(() {
  return ChatController();
});
