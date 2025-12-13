import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  late String chatId;
  late String myId;

  @override
  void initState() {
    super.initState();

    myId = FirebaseAuth.instance.currentUser!.uid;
    chatId = _getChatId(myId, widget.receiverId);

    context.read<ChatBloc>().add(LoadMessages(chatId));
  }

  /// ✅ FIX: chat id generator
  String _getChatId(String a, String b) {
    return a.compareTo(b) < 0 ? '$a-$b' : '$b-$a';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          /// 🔥 MESSAGES
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) {
                      final msg = state.messages[i];
                      final isMe = msg.senderId == myId;

                      /// 👀 mark seen
                      if (!isMe && !msg.seen) {
                        context.read<ChatBloc>().add(
                              MarkSeen(
                                chatId: chatId,
                                messageId: msg.id,
                              ),
                            );
                      }

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isMe ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color:
                                      isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              if (isMe)
                                Icon(
                                  msg.seen
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          /// ✍️ INPUT
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onChanged: (v) {
                    context.read<ChatBloc>().add(
                          TypingEvent(
                            receiverId: widget.receiverId,
                            isTyping: v.isNotEmpty,
                          ),
                        );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;

                  context.read<ChatBloc>().add(
                        SendMessage(
                          chatId: chatId,
                          receiverId: widget.receiverId,
                          text: text,
                        ),
                      );
                  controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
