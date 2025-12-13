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
  final ScrollController scrollController = ScrollController();

  late String myId;
  late String chatId;

  @override
  void initState() {
    super.initState();
    myId = FirebaseAuth.instance.currentUser!.uid;

    chatId = myId.compareTo(widget.receiverId) < 0
        ? '$myId-${widget.receiverId}'
        : '${widget.receiverId}-$myId';

    context.read<ChatBloc>().add(LoadMessages(chatId));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🌿 Soft bubble colors
  Color _bubbleColor({required bool isMe, required bool seen}) {
    if (isMe) {
      return seen
          ? const Color(0xFFE8F5E9) // seen (soft green)
          : const Color(0xFFE3F2FD); // sent (soft blue)
    } else {
      return const Color(0xFFF1F3F4); // received (soft grey)
    }
  }

  /// 📝 Text color
  Color _textColor(bool isMe) {
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// 🔝 AppBar (clean & calm)
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE3F2FD),
              child: Text(
                widget.receiverName[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.receiverName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          /// 💬 Messages
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatLoaded) {
                  _scrollToBottom();

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) {
                      final msg = state.messages[i];
                      final isMe = msg.senderId == myId;

                      /// 👀 Mark seen silently
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
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.72,
                          ),
                          decoration: BoxDecoration(
                            color: _bubbleColor(
                              isMe: isMe,
                              seen: msg.seen,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft:
                                  Radius.circular(isMe ? 18 : 6),
                              bottomRight:
                                  Radius.circular(isMe ? 6 : 18),
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: _textColor(isMe),
                              fontSize: 15,
                              height: 1.45,
                            ),
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

          /// ✍️ Input field (soft & premium)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type a message…",
                      filled: true,
                      fillColor: const Color(0xFFF1F3F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF90CAF9),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
