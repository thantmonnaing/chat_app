import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsecureText;

  const MyTextField(
      {super.key, required this.controller, required this.hintText, required this.obsecureText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10),
      child: TextField(
        obscureText:obsecureText,
        controller: controller,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme
                    .of(context)
                    .colorScheme
                    .tertiary)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme
                    .of(context)
                    .colorScheme
                    .primary)
            ),
            fillColor: Theme
                .of(context)
                .colorScheme
                .tertiary,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary)
        ),

      ),
    );
  }
}
