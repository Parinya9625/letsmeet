import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // TODO:  Temp BG
            image: AssetImage('lib/assets/images/WelcomeBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),
              // TODO: Temp App logo
              Image.asset('lib/assets/images/google_icon.png'),
              const Spacer(flex: 3),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      // TODO: Add onPressed function
                      onPressed: () {},
                      child: const Text("GET STARTED"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      // TODO: Add onPressed
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).cardColor,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).textTheme.headline1!.color,
                        ),
                        overlayColor: MaterialStateProperty.all(
                          Theme.of(context).disabledColor,
                        ),
                      ),
                      child: const Text("SIGN IN"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
