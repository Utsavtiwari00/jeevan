import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/utils/formatters.dart';
import 'package:jeevan/application/chat/chat_provider.dart';
import 'package:jeevan/domain/models/chat_message.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/chat/formatted_chat_text.dart';

class JeevanAssistantScreen extends ConsumerStatefulWidget {
  final bool isPushedRoute;

  const JeevanAssistantScreen({
    super.key,
    this.isPushedRoute = true,
  }) : super();

  @override
  ConsumerState<JeevanAssistantScreen> createState() => _JeevanAssistantScreenState();
}

class _JeevanAssistantScreenState extends ConsumerState<JeevanAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendMessage(text.trim());
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final isSending = ref.watch(chatControllerProvider);
    final suggestedPromptsAsync = ref.watch(suggestedPromptsProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(
        showBackButton: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jeevan Assistant',
              style: TextStyle(
                color: AppColors.charcoalSoil,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Ask about your field',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const ChatSkeleton(),
                error: (err, stack) => Center(child: Text('Error loading chat', style: TextStyle(color: AppColors.criticalRed))),
                data: (messages) {
                  final reversedMessages = messages.reversed.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Newest messages at bottom
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: reversedMessages.length + (isSending.value == true ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isSending.value == true && index == 0) {
                         return const _TypingIndicator();
                      }
                      
                      final msgIndex = isSending.value == true ? index - 1 : index;
                      final message = reversedMessages[msgIndex];
                      
                      return _ChatBubble(message: message);
                    },
                  );
                },
              ),
            ),
            
            // Suggested Prompts
            suggestedPromptsAsync.when(
              data: (prompts) {
                if (prompts.isEmpty) return const SizedBox.shrink();
                return Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: prompts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ActionChip(
                          label: Text(prompts[index]),
                          backgroundColor: AppColors.surfaceWhite,
                          side: const BorderSide(color: AppColors.divider),
                          labelStyle: const TextStyle(color: AppColors.accentGreen, fontSize: 13),
                          onPressed: () {
                            _sendMessage(prompts[index]);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask Jeevan about your field...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        filled: true,
                        fillColor: AppColors.paperBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                      enabled: isSending.value != true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.surfaceWhite, size: 20),
                      onPressed: isSending.value == true 
                          ? null 
                          : () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology, color: AppColors.surfaceWhite, size: 14),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.accentGreen : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.md),
                      topRight: const Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(isUser ? AppRadius.md : 2),
                      bottomRight: Radius.circular(isUser ? 2 : AppRadius.md),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormattedChatText(
                        text: message.text,
                        isUser: isUser,
                        baseStyle: TextStyle(
                          color: isUser ? AppColors.surfaceWhite : AppColors.charcoalSoil,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (message.attachedData != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _StructuredDataEmbed(data: message.attachedData!),
                      ]
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 24 + AppSpacing.sm), // Keep alignment symmetrical
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.xs,
              left: isUser ? 0 : 24 + AppSpacing.sm,
              right: isUser ? 24 + AppSpacing.sm : 0,
            ),
            child: Text(
              Formatters.formatTime(message.timestamp),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StructuredDataEmbed extends StatelessWidget {
  final Map<String, dynamic> data;

  const _StructuredDataEmbed({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.containsKey('zones')) {
      final zones = data['zones'] as List<dynamic>;
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.paperBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: zones.map((z) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(z['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.charcoalSoil)),
                Text('${z['moisture'] ?? ''}%', style: const TextStyle(color: AppColors.textSecondary)),
                Text(z['status'] ?? '', style: TextStyle(
                  color: z['status'] == 'Very Low' ? AppColors.criticalRed : AppColors.charcoalSoil,
                  fontSize: 12,
                )),
              ],
            ),
          )).toList(),
        ),
      );
    }
    
    if (data.containsKey('rover')) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.paperBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.radar, size: 20, color: AppColors.textSecondary),
            Text(data['rover'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('${data['battery'] ?? ''}%', style: const TextStyle(color: AppColors.accentGreen)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: AppColors.surfaceWhite, size: 14),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(AppRadius.md),
              ),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 12,
                  child: Center(
                    child: Text('...', style: TextStyle(color: AppColors.textSecondary, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
