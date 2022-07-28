import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoGroupChatBanner extends StatefulWidget {
  final VoidCallback? onPressed;

  const NoGroupChatBanner({Key? key, this.onPressed}) : super(key: key);

  @override
  State<NoGroupChatBanner> createState() => _NoGroupChatBannerState();
}

class _NoGroupChatBannerState extends State<NoGroupChatBanner> {
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
              child: FaIcon(
                FontAwesomeIcons.comments,
                size: 150,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "No Group Chat",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "You didn't have any upcoming event for chat with other",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
