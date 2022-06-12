import 'package:flutter/material.dart';

class NoConnectionBanner extends StatefulWidget {
  final VoidCallback onPressed;

  const NoConnectionBanner({Key? key, required this.onPressed})
      : super(key: key);

  @override
  State<NoConnectionBanner> createState() => _NoConnectionBannerState();
}

class _NoConnectionBannerState extends State<NoConnectionBanner> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 150,
                color: Colors.blue,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "No Connection",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No internet connection found. Check your connection or try again",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Try again'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
