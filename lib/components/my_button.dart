import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String btnText;
  final void Function()? onTap;

  const MyButton({super.key, required this.btnText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10)),
        child: Center(
            child: Text(
          btnText,
          style: const TextStyle(fontSize: 18),
        )),
      ),
    );
  }
}
