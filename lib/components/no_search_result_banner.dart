import 'package:flutter/material.dart';

class NoSearchResultBanner extends StatefulWidget {
  const NoSearchResultBanner({Key? key}) : super(key: key);

  @override
  State<NoSearchResultBanner> createState() => _NoSearchResultBannerState();
}

class _NoSearchResultBannerState extends State<NoSearchResultBanner> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.search_off_rounded,
                size: 150,
                color: Colors.blue,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "No Search Result",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No search result found. Please use another Keyword",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
