import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:intl/intl.dart';

import 'package:jeevan/widgets/chat/formatted_chat_text.dart';

/// Chat message bubble.
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final Widget? attachedData;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.attachedData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isUser ? AppColors.accentGreen : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg).copyWith(
                bottomRight: isUser ? Radius.zero : const Radius.circular(AppRadius.lg),
                bottomLeft: !isUser ? Radius.zero : const Radius.circular(AppRadius.lg),
              ),
              border: isUser ? null : Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormattedChatText(
                  text: message,
                  isUser: isUser,
                  baseStyle: AppTypography.bodyMedium.copyWith(
                    color: isUser ? AppColors.surfaceWhite : AppColors.charcoalSoil,
                  ),
                ),
                if (attachedData != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  attachedData!,
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('h:mm a').format(timestamp),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
