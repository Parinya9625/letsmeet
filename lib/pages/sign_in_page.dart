import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/textfield_extension.dart';
import 'package:letsmeet/components/continue_with_google.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ).withElevation(),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              ).withElevation(),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      TextSpan(
                        text: "Forget Password ?",
                        style: Theme.of(context).textTheme.headline3,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Forget password
                          },
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Sign in
                  print(
                      "Email: ${emailController.text.trim()}, Password: ${passwordController.text.trim()}");
                },
                child: const Text("SIGN IN"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                  ],
                ),
              ),
              ContinueWithGoogleButton(
                onPressed: () {
                  // TODO: Continue with google
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      const TextSpan(
                        text: "Don't have an account? ",
                      ),
                      TextSpan(
                        text: "Sign up",
                        style: Theme.of(context).textTheme.headline3,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Sign up
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
