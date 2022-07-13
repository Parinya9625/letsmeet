import 'package:flutter/material.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    User? lmUser = context.watch<User?>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (lmUser != null) ...{
                Image.network(
                  lmUser.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
                Text(lmUser.name),
                Text(lmUser.surname),
                TextButton(
                  child: const Text("Sign out"),
                  onPressed: () {
                    context.read<AuthenticationService>().signOut();
                  },
                ),
              } else ...{
                const CircularProgressIndicator(),
              }
            ],
          ),
        ),
      ),
    );
  }
}
