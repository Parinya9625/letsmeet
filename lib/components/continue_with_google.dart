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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Card(
        elevation: widget.onPressed != null ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/google_icon.png',
                height: 24,
                width: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                child: Text(
                  'Continue with Google',
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
