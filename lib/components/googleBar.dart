import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class googleButton extends StatefulWidget {
  const googleButton({Key? key}) : super(key: key);

  @override
  State<googleButton> createState() => _googleButtonState();
}

class _googleButtonState extends State<googleButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextButton.icon(
        icon: Image.asset(
          'lib/assets/images/google_Logo.png',
          height: 30,
          width: 30,
        ),
        onPressed: () {},
        style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)))),
        label: const Text('Continue with google'),
      ),
    );
  }
}
