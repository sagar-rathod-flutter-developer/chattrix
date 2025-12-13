abstract class ChatEvent {}

/// 🔥 Load messages
class LoadMessages extends ChatEvent {
  final String chatId;

  LoadMessages(this.chatId);
}

/// ✉️ Send message
class SendMessage extends ChatEvent {
  final String chatId;
  final String receiverId;
  final String text;

  SendMessage({
    required this.chatId,
    required this.receiverId,
    required this.text,
  });
}

/// 👀 Mark message as seen
class MarkSeen extends ChatEvent {
  final String chatId;
  final String messageId;

  MarkSeen({
    required this.chatId,
    required this.messageId,
  });
}

/// ✍️ Typing indicator
class TypingEvent extends ChatEvent {
  final String receiverId;
  final bool isTyping;

  TypingEvent({
    required this.receiverId,
    required this.isTyping,
  });
}
