import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class NoSearchResult extends StatefulWidget {
  const NoSearchResult({Key? key}) : super(key: key);

  @override
  State<NoSearchResult> createState() => _NoSearchResultState();
}

class _NoSearchResultState extends State<NoSearchResult> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(children: [
          Icon(
            Icons.search_off,
            size: 150,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              child: Text(
                "No search Result",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "No search result found. Please use another \n Keyword",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ]),
      ),
    );
  }
}
