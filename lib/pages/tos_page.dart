import 'package:flutter/material.dart';

class TOSPage extends StatefulWidget {
  const TOSPage({Key? key}) : super(key: key);

  @override
  State<TOSPage> createState() => _TOSPageState();
}

class _TOSPageState extends State<TOSPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: const [
              Text("😴"),
              Text("😴"),
              Text("😴"),
              Text("😴"),
              Text("😴"),
              Text("😴"),
              Text("😴"),
              Text("😴"),
              Text("😴"),
            ],
          ),
        ),
      ),
    );
  }
}
