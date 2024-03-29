import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/continue_with_google.dart';
import 'package:letsmeet/services/authentication.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign in error'),
          content: Text(message),
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
        });
  }

  Widget signInForm() {
    return SizedBox(
      width: 512,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Wrap(
            runSpacing: 16,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Sign in",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputField(
                      controller: emailController,
                      elevation: 0,
                      backgroundColor: Theme.of(context).disabledColor,
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
                    const SizedBox(height: 16),
                    InputField(
                      controller: passwordController,
                      elevation: 0,
                      backgroundColor: Theme.of(context).disabledColor,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      hintText: 'Password',
                      icon: const Icon(Icons.lock_rounded),
                      onClear: () {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password\n";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          showLoading();

                          AuthenticationResult result = await context
                              .read<AuthenticationService>()
                              .signIn(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                          if (result != AuthenticationResult.success) {
                            Navigator.pop(context);
                            showErrorDialog(result.message);
                          }
                        }
                      },
                      child: const Text("SIGN IN"),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
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
              ContinueWithGoogleButton(onPressed: () async {
                showLoading();

                AuthResultWithUserInfo result = await context
                    .read<AuthenticationService>()
                    .signInWithGoogle();

                if (result.result == AuthenticationResult.googleSigninDismiss) {
                  Navigator.pop(context);
                } else if (result.result == AuthenticationResult.success) {
                  //
                } else {
                  Navigator.pop(context);
                  showErrorDialog(result.result.message);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: signInForm(),
      ),
    );
  }
}
