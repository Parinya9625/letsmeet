import 'package:flutter/material.dart';
import 'package:letsmeet/components/textfield_extension.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Forgot password ?",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              Text(
                "Enter your email address, we'll send you an email to reset you password.",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ).withElevation(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Submit
                  print(
                      "Email: ${emailController.text.trim()} ${DateTime.now()}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Email sent successfully, please check your email !",
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("SUBMIT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
