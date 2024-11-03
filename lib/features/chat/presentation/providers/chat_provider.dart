import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:teachmate_pro/features/chat/domain/models/chat_message.dart';
import 'package:teachmate_pro/features/ai/presentation/providers/ai_provider.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}

final chatControllerProvider = Provider((ref) => ChatController(ref));

class ChatController {
  final Ref _ref;
  final _uuid = const Uuid();

  ChatController(this._ref);

  void clearChat() {
    _ref.read(chatMessagesProvider.notifier).clearMessages();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      isUser: true,
      type: MessageType.text,
    );

    _ref.read(chatMessagesProvider.notifier).addMessage(userMessage);

    try {
      final response = await _ref.read(aiControllerProvider).sendMessage(
            message: text,
          );

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response,
        isUser: false,
        type: MessageType.text,
      );

      _ref.read(chatMessagesProvider.notifier).addMessage(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.',
        isUser: false,
        type: MessageType.text,
      );
      _ref.read(chatMessagesProvider.notifier).addMessage(errorMessage);
    }
  }
}
