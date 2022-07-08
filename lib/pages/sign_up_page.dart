import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/checkbox_tile.dart';
import 'package:letsmeet/components/continue_with_google.dart';
import 'package:letsmeet/components/controllers/checkbox_tile_controller.dart';
import 'package:letsmeet/components/textfield_extension.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  DateTime? birthday;
  TextEditingController birthdayController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  CheckboxTileController tosController = CheckboxTileController();

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
                "Create account",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              ContinueWithGoogleButton(
                onPressed: () {
                  // TODO: Continue with google
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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ).withElevation(),
              const SizedBox(height: 16),
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(
                  hintText: 'Surname',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ).withElevation(),
              const SizedBox(height: 16),
              GestureDetector(
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
                child: TextField(
                  enabled: false,
                  controller: birthdayController,
                  decoration: InputDecoration(
                    hintText: 'Birthday',
                    prefixIcon: Icon(
                      Icons.cake_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ).withElevation(),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              ).withElevation(),
              const SizedBox(height: 16),
              CheckboxTile(
                controller: tosController,
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
                            print(DateTime.now());
                          },
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
              ),
              //

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Sign up
                  print("""
                    Name: ${nameController.text}
                    Surname: ${surnameController.text}
                    Birthday: $birthday
                    Email: ${emailController.text}
                    Password: ${passwordController.text}
                    Confirm: ${confirmPasswordController.text}
                    TOS: ${tosController.value}
                  """);
                },
                child: const Text("SIGN UP"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
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
                            // TODO: Sign in
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
