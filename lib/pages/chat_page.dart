import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/chat_bubble.dart';
import '../components/my_drawer.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  ChatPage({super.key, required this.receiverEmail, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // chat & auth services
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  //message textField
  TextEditingController _messageTextController = TextEditingController();

  //send message function
  void sendMessage() async {
    if (_messageTextController.text.isNotEmpty) {
      await _chatService
          .sendMessage(widget.receiverId, _messageTextController.text)
          .then((_) => _messageTextController.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
      ),
      body: Column(
        children: [
          //message list
          Expanded(child: _buildMessageList()),
          _messageField(),
          const SizedBox(
            height: 30,
          )

          //message text field
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(senderId, widget.receiverId),
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return const Text("Error...");
          }

          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          // return list data
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is currentuser?

    bool isCurrentUser = data["uid"] == _authService.getCurrentUser()!.uid;

    final aligment =
        isCurrentUser ? Alignment.centerLeft : Alignment.centerRight;

    return
      Container(
      alignment: aligment,
      child: ChatBubble(
        alignment: aligment,
        text: data["message"],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

  // message text field

  Widget _messageField() {
    return Row(
      children: [
        Expanded(
            child: MyTextField(
                controller: _messageTextController,
                obsecureText: false,
                hintText: "Type a message...")),
        Container(
          color: Theme.of(context).colorScheme.primary,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        )
      ],
    );
  }
}
