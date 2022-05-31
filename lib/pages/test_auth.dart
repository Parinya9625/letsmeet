import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:provider/provider.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Text(user.toString()),
            TextButton(
              child: const Text("Sign out"),
              onPressed: () {
                context.read<AuthenticationService>().signOut();
              },
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextField(
              controller: _username,
            ),
            TextField(
              controller: _password,
            ),
            TextButton(
              onPressed: () {
                context.read<AuthenticationService>().signIn(
                      email: _username.text.trim(),
                      password: _password.text.trim(),
                    );
              },
              child: const Text("Sign in"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthenticationService>().signUp(
                      email: _username.text.trim(),
                      password: _password.text.trim(),
                    );
              },
              child: const Text("Sign up"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthenticationService>().signInWithGoogle();
              },
              child: const Text("Sign in Google"),
            ),
            TextButton(
              onPressed: () {
              },
              child: const Text("Forget password"),
            ),
            
          ],
        ),
      );
    }
  }
}
