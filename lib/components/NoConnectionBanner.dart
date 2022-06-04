import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class NoConnectionBanner extends StatefulWidget {
  const NoConnectionBanner({Key? key}) : super(key: key);

  @override
  State<NoConnectionBanner> createState() => _NoConnectionBannerState();
}

class _NoConnectionBannerState extends State<NoConnectionBanner> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(children: [
          Icon(
            Icons.wifi_off,
            size: 150,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              child: Text(
                "No Connection",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "No internet connection found. Check your connection or try again",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Container(
            child: ElevatedButton(
                onPressed: () {},
                child: Text('Try again'),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue,
                          ))),
                )),
          )
        ]),
      ),
    );
  }
}
