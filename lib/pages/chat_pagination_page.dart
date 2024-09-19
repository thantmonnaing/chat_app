import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/chat_bubble.dart';
import '../services/state/chat_state.dart';

class ChatPaginationPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;
  const ChatPaginationPage({Key? key, required this.receiverEmail, required this.receiverId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Pagination')),
      body: MessageList(receiverId:receiverId)
    );
  }
}

class MessageList extends StatefulWidget {
  final String receiverId;
  const MessageList({
    Key? key, required this.receiverId,
  }) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<ChatState>(context, listen: false)
        .initialState(10, widget.receiverId);
  }
  @override
  Widget build(BuildContext context) {
    // final users = context.select((HomeState value) => value.users);
    final messages = context.watch<ChatState>().messages;

    final read = context.read<ChatState>();
    return ListView.builder(
      itemCount: messages.length,
      controller: read.homeScrollController,
      itemBuilder: (_, index) {
        return ChatBubble(
          text: messages[index].message,
          isCurrentUser: true,
        );
      },
    );
  }
}

class SomeWidget extends StatelessWidget {
  const SomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final read = context.read<ChatState>();

    return InkWell(
      onTap: () => read.setLoading(true),
      child: Text(read.messages.length.toString()),
    );
  }
}
