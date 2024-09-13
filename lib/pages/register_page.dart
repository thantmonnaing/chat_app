import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function() onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _pwsController = TextEditingController();

  TextEditingController _confirmPwsController = TextEditingController();

  void register(BuildContext context) async{
    final _auth = AuthService();
    //check password and confirm password

    if (_pwsController.text == _confirmPwsController.text) {
      try {
        _auth.signUpWithEmailAndPassword(
            _emailController.text, _pwsController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(e.toString()),
                ));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Password don't match"),
              ));
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
              "Let's create an account!",
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

            // confirm password field

            MyTextField(
              obsecureText: true,
              controller: _confirmPwsController,
              hintText: "Confirm Password",
            ),

            const SizedBox(
              height: 25,
            ),
            // login btn
            MyButton(
              btnText: "Register",
              onTap: () => register(context),
            ),
            const SizedBox(
              height: 25,
            ),

            // register

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Have an account? ",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login",
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
