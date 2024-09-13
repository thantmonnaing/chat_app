import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final bool isCurrentUser;
  final Alignment alignment;
  final String text;

  const ChatBubble(
      {super.key, required this.isCurrentUser, required this.alignment,required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 25),
      child: Text(text,style: const TextStyle(color: Colors.white),),
    );
  }
}
