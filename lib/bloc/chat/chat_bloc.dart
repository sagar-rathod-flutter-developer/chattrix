import 'package:chattrix/bloc/chat/chat_event.dart';
import 'package:chattrix/bloc/chat/chat_state.dart';
import 'package:chattrix/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatLoading()) {
    on<LoadMessages>(_loadMessages);
    on<SendMessage>(_sendMessage);
    on<MarkSeen>(_markSeen);
    on<TypingEvent>(_typing);
  }

  Future<void> _loadMessages(
      LoadMessages event, Emitter<ChatState> emit) async {

    await emit.forEach(
      FirebaseFirestore.instance
          .collection('chats')
          .doc(event.chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      onData: (snapshot) {
        final messages = snapshot.docs
            .map((doc) =>
                MessageModel.fromDoc(doc.id, doc.data()))
            .toList();
        return ChatLoaded(messages);
      },
    );
  }

  Future<void> _sendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(event.chatId)
        .collection('messages')
        .add({
      'senderId': myId,
      'receiverId': event.receiverId,
      'text': event.text,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
    });

    // update last message
    await FirebaseFirestore.instance
        .collection('users')
        .doc(event.receiverId)
        .update({
      'lastMessage': event.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _markSeen(
      MarkSeen event, Emitter<ChatState> emit) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(event.chatId)
        .collection('messages')
        .doc(event.messageId)
        .update({'seen': true});
  }

  Future<void> _typing(
      TypingEvent event, Emitter<ChatState> emit) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({
      'typingTo': event.isTyping ? event.receiverId : null
    });
  }
}
