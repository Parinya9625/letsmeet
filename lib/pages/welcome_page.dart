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

  //* pass
  // 1, 4, 

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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      String last = listBGImage.removeLast();
                      listBGImage.insert(0, last);
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'lib/assets/images/icon/letsmeet-icon.png',
                      width: 128,
                      height: 128,
                    ),
                  ),
                ),
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
