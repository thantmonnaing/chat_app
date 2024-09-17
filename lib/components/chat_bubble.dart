import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final bool isCurrentUser;
  final String text;

  const ChatBubble(
      {super.key, required this.isCurrentUser, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ?
        (isCurrentUser ? Colors.green.withOpacity(0.8) : Colors.grey.withOpacity(0.2)) : (isCurrentUser ? Colors.green : Colors.grey),
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 25),
      child: Text(text,style: const TextStyle(color: Colors.white),),
    );
  }
}
