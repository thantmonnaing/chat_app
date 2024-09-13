import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function() onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _pwsController = TextEditingController();

  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    try {
      authService.signInWithEmailAndPassword(
          _emailController.text, _pwsController.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(
              height: 15,
            ),
            // welcome message

            Text(
              "Welcome to my chat app",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),

            // email field
            MyTextField(
              obsecureText: false,
              controller: _emailController,
              hintText: "Email",
            ),

            // password field
            MyTextField(
              obsecureText: true,
              controller: _pwsController,
              hintText: "Password",
            ),
            const SizedBox(
              height: 25,
            ),
            // login btn
            MyButton(
              btnText: "Login",
              onTap: () => login(context),
            ),
            const SizedBox(
              height: 25,
            ),

            // register

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Register Now",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
