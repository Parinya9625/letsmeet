import 'package:flutter/material.dart';

class NoEventBanner extends StatefulWidget {
  final VoidCallback? onPressed;

  const NoEventBanner({Key? key, this.onPressed}) : super(key: key);

  @override
  State<NoEventBanner> createState() => _NoEventBannerState();
}

class _NoEventBannerState extends State<NoEventBanner> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.event_busy_rounded,
                size: 150,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "No Event",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No event found. Please check this page later or create new event",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                child: const Text('Reload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
