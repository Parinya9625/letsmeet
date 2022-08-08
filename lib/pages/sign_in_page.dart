// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/continue_with_google.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:provider/provider.dart';

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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
                        const SizedBox(height: 16),
                        InputField(
                          controller: passwordController,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
                    child: RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: [
                          TextSpan(
                            text: "Forgot password?",
                            style: Theme.of(context).textTheme.headline3,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, "/signin/forgot");
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        showLoading();

                        AuthenticationResult result =
                            await context.read<AuthenticationService>().signIn(
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
                  Padding(
                    padding: const EdgeInsets.all(32),
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
                    onPressed: () async {
                      showLoading();

                      AuthResultWithUserInfo result = await context
                          .read<AuthenticationService>()
                          .signInWithGoogle();

                      if (result.result ==
                          AuthenticationResult.googleSigninDismiss) {
                        Navigator.pop(context);
                      } else if (result.result ==
                          AuthenticationResult.success) {
                        final doc = await FirebaseFirestore.instance
                            .collection("users")
                            .doc(result.uid)
                            .get();

                        if (!doc.exists) {
                          User user = User.createWithID(
                            id: result.uid,
                            birthday: result.birthday!,
                            image: result.photoUrl!,
                            name: result.name!,
                            surname: result.surname!,
                          );

                          context
                              .read<CloudFirestoreService>()
                              .addUser(user: user);
                        }
                      } else {
                        Navigator.pop(context);
                        showErrorDialog(result.result.message);
                      }
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
                                Navigator.pushNamed(context, "/signup");
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
        ),
      ),
    );
  }
}
