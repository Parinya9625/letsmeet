// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/checkbox_tile.dart';
import 'package:letsmeet/components/continue_with_google.dart';
import 'package:letsmeet/components/controllers/checkbox_tile_controller.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  DateTime? birthday;
  TextEditingController birthdayController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  CheckboxTileController tosController = CheckboxTileController();
  GlobalKey<CheckboxTileState> tosKey = GlobalKey();

  Future<DateTime?> _showDatePicker(DateTime? value) async {
    DateTime? date = await showDatePicker(
        initialDate: value ?? DateTime.now(),
        context: context,
        firstDate: DateTime.parse("1900-01-01"),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Theme.of(context).textTheme.headline1!.color,
                  ),
            ),
            child: child!,
          );
        });

    return date;
  }

  showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign up error'),
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
            controller: ScrollController(),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create account",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
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
                            createdTime: result.createdTime,
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

                  //
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InputField(
                          controller: nameController,
                          hintText: 'Name',
                          icon: const Icon(Icons.person_rounded),
                          onClear: () {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your name\n";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          controller: surnameController,
                          hintText: 'Surname',
                          icon: const Icon(Icons.person_rounded),
                          onClear: () {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your surname\n";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          readOnly: true,
                          controller: birthdayController,
                          hintText: 'Birthday',
                          icon: const Icon(Icons.cake_rounded),
                          onTap: () async {
                            DateTime? date = await _showDatePicker(birthday);

                            setState(() {
                              birthday = date ?? birthday;
                              if (birthday != null) {
                                birthdayController.text =
                                    DateFormat("dd MMM y").format(birthday!);
                              }
                            });
                          },
                          validator: (value) {
                            var now = DateTime.now();
                            var ageLimitDay =
                                DateTime(now.year - 18, now.month, now.day);

                            if (value == null || value.isEmpty) {
                              return "Please select your birthday\n";
                            } else if (birthday!.isAfter(ageLimitDay)) {
                              return "User over 18 can't sign up\n";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          controller: emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          icon: const Icon(Icons.email_rounded),
                          onClear: () {},
                          validator: (value) {
                            RegExp emailPattern = RegExp(
                                r"^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$",
                                multiLine: true);
                            if (value == null || value.isEmpty) {
                              return "Please enter your email\n";
                            } else if (!emailPattern.hasMatch(value.trim())) {
                              return "Email address is badly formatted\n";
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
                            } else if (value.trim().length < 8) {
                              return "Password must be at least 8 characters\n";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          hintText: 'Confirm Password',
                          icon: const Icon(Icons.lock_rounded),
                          onClear: () {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password\n";
                            } else if (passwordController.text.trim() !=
                                value.trim()) {
                              return "Password is not matched\n";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CheckboxTile(
                          key: tosKey,
                          controller: tosController,
                          errorText: "You must agree to the Terms of Service\n",
                          title: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headline1,
                              children: [
                                const TextSpan(
                                  text:
                                      "I confirm that I have read and agree to LetsMeet ",
                                ),
                                TextSpan(
                                  text: "Terms of Service",
                                  style: Theme.of(context).textTheme.headline3,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: Terms of Service
                                    },
                                ),
                                const TextSpan(text: "."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      bool tosV = tosKey.currentState!.validate();
                      bool formV = formKey.currentState!.validate();

                      if (formV && tosV) {
                        showLoading();

                        AuthResultWithUserInfo result = await context
                            .read<AuthenticationService>()
                            .signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim());

                        if (result.result == AuthenticationResult.success) {
                          User user = User.createWithID(
                            id: result.uid,
                            birthday: birthday!,
                            image:
                                "https://avatars.dicebear.com/api/identicon/${result.uid}.png?size=64&backgroundColor=white",
                            name: nameController.text.trim(),
                            surname: surnameController.text.trim(),
                          );

                          context
                              .read<CloudFirestoreService>()
                              .addUser(user: user);
                        } else {
                          Navigator.pop(context);
                          showErrorDialog(result.result.message);
                        }
                      }
                    },
                    child: const Text("SIGN UP"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: [
                          const TextSpan(
                            text: "Already have an account? ",
                          ),
                          TextSpan(
                            text: "Sign in",
                            style: Theme.of(context).textTheme.headline3,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, "/signin");
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
