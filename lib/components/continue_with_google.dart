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
    return ElevatedButton.icon(
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
      style: ButtonStyle(
        textStyle:
            MaterialStateProperty.all(Theme.of(context).textTheme.headline1),
        foregroundColor: MaterialStateProperty.all(
            Theme.of(context).textTheme.headline1!.color),
        backgroundColor: MaterialStateProperty.all(Theme.of(context).cardColor),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(56)),
      ),
      onPressed: widget.onPressed,
    );
  }
}
