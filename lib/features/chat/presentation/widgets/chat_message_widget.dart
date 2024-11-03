import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/formatted_ai_content.dart';
import 'package:teachmate_pro/features/chat/domain/models/chat_message.dart';
import 'package:intl/intl.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final ChatMessage? previousMessage;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.previousMessage,
  });

  bool get _showTimestamp {
    if (previousMessage == null) return true;
    final difference = message.timestamp.difference(previousMessage!.timestamp);
    return difference.inMinutes > 5 ||
        previousMessage!.isUser != message.isUser;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 64 : 0,
        right: message.isUser ? 0 : 64,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (_showTimestamp)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: message.isUser ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isUser ? 16 : 2),
                bottomRight: Radius.circular(message.isUser ? 2 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: (message.isUser ? AppColors.primary : Colors.black)
                      .withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: _buildMessageContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return DefaultTextStyle(
          style: AppTextStyles.bodyMedium.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
          child: FormattedAIContent(
            content: message.content,
            baseStyle: AppTextStyles.bodyMedium.copyWith(
              color: message.isUser ? Colors.white : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              color: message.isUser ? Colors.white : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Ses mesajı',
              style: AppTextStyles.bodyMedium.copyWith(
                color: message.isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        );
    }
  }
}
