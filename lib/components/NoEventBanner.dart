import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class NoEventBanner extends StatefulWidget {
  const NoEventBanner({Key? key}) : super(key: key);

  @override
  State<NoEventBanner> createState() => _NoEventBannerState();
}

class _NoEventBannerState extends State<NoEventBanner> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(children: [
          Icon(
            Icons.event_busy,
            size: 150,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              child: Text(
                "No Event",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "No event found. Please check this page later or create new event",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Container(
            child: ElevatedButton(
                onPressed: () {},
                child: Text('Reload'),
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
