import 'package:flutter/material.dart';

class ContinueWithGoogleButton extends StatefulWidget {
  const ContinueWithGoogleButton({Key? key, this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  State<ContinueWithGoogleButton> createState() =>
      _ContinueWithGoogleButtonState();
}

class _ContinueWithGoogleButtonState extends State<ContinueWithGoogleButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Image.asset(
        'lib/assets/images/google_icon.png',
        height: 24,
        width: 24,
      ),
      label: const Padding(
        padding: EdgeInsets.only(
          left: 16,
        ),
        child: Text('Continue with Google'),
      ),
      style: TextButton.styleFrom(
        primary: Colors.black,
        backgroundColor: Colors.white,
        elevation: 1.0,
        minimumSize: const Size.fromHeight(56),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
      ),
      onPressed: widget.onPressed,
    );
  }
}
