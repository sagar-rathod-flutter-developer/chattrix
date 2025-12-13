// bloc/chat/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import '../../models/message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatLoading()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    final stream = FirebaseFirestore.instance
        .collection('chats')
        .doc(event.chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();

    await emit.forEach<QuerySnapshot>(
      stream,
      onData: (snapshot) {
        final messages = snapshot.docs
            .map((doc) =>
                MessageModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ChatLoaded(messages);
      },
      onError: (error, _) => ChatError(error.toString()),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(event.chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'receiverId': event.receiverId,
      'text': event.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
