import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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

  FocusNode focusNode = FocusNode();

  //message textField
  TextEditingController _messageTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // first time scroll
    Future.delayed(const Duration(milliseconds: 500), () => _scrollPosition());

    // textField focus scroll position
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
            const Duration(milliseconds: 500), () => _scrollPosition());
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    focusNode.dispose();
    _messageTextController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  void _scrollPosition() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  //send message function
  void sendMessage() async {
    if (_messageTextController.text.isNotEmpty) {
      await _chatService
          .sendMessage(widget.receiverId, _messageTextController.text)
          .then((_) {
        _messageTextController.clear();
        _scrollPosition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
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
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is currentuser?

    bool isCurrentUser = data["senderId"] == _authService.getCurrentUser()!.uid;

    final aligment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: aligment,
      child: ChatBubble(
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
                focusNode: focusNode,
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
