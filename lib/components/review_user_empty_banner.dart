import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReviewUserEmptyBanner extends StatefulWidget {
  final VoidCallback? onPressed;

  const ReviewUserEmptyBanner({Key? key, this.onPressed}) : super(key: key);

  @override
  State<ReviewUserEmptyBanner> createState() => _ReviewUserEmptyBannerState();
}

class _ReviewUserEmptyBannerState extends State<ReviewUserEmptyBanner> {
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
                FontAwesomeIcons.ghost,
                size: 150,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Oops..",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "You don't have anyone to review in this event",
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
