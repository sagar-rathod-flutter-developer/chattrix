class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final bool seen;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.seen,
  });

  factory MessageModel.fromDoc(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      text: map['text'],
      seen: map['seen'] ?? false,
    );
  }
}
