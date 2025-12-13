// bloc/chat/chat_event.dart
abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String chatId;
  LoadMessages(this.chatId);
}

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
