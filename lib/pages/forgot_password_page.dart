// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  showLoading() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }

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
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputField(
                      controller: emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      icon: const Icon(Icons.email_rounded),
                      onClear: () {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email\n";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    showLoading();

                    AuthenticationResult result = await context
                        .read<AuthenticationService>()
                        .resetPassword(
                          email: emailController.text.trim(),
                        );

                    if (result == AuthenticationResult.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Email sent successfully, please check your email !",
                          ),
                        ),
                      );
                      Navigator.popUntil(
                          context, ModalRoute.withName('/signin'));
                    } else {
                      Navigator.pop(context);
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Forgot password error'),
                            content: Text(result.message),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Done'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
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
