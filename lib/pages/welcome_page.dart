import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<String> listBGImage = [
    "lib/assets/images/welcome_bg_1.jpg",
    "lib/assets/images/welcome_bg_2.jpg",
    "lib/assets/images/welcome_bg_3.jpg",
    "lib/assets/images/welcome_bg_4.jpg",
    "lib/assets/images/welcome_bg_5.jpg",
  ];

  @override
  void initState() {
    super.initState();

    listBGImage.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(listBGImage.first),
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
                        onPressed: () {
                          Navigator.pushNamed(context, "/signup");
                        },
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
                        onPressed: () {
                          Navigator.pushNamed(context, "/signin");
                        },
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
      ),
    );
  }
}
