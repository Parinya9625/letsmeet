import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:letsmeet/components/all.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/search_filter_base.dart';
import 'package:letsmeet/components/search_filter_category.dart';
import 'package:letsmeet/components/search_filter_date.dart';
import 'package:letsmeet/components/search_filter_distance.dart';
import 'package:letsmeet/components/search_filter_type.dart';
import 'package:letsmeet/components/search_event_card.dart';

import '../models/event.dart';

class SearchEventPage extends StatefulWidget {
  const SearchEventPage({Key? key}) : super(key: key);

  @override
  State<SearchEventPage> createState() => _SearchEventPageState();
}

class _SearchEventPageState extends State<SearchEventPage> {
  Event event = Event.createInPerson(
    ageRestrict: false,
    category: FirebaseFirestore.instance
        .collection("categories")
        .doc("BL9JCjK3rnkbN3pBqgro"),
    description: "des",
    image:
        "https://avatars.dicebear.com/api/identicon/event.png?size=64&backgroundColor=white",
    placeId: "placeId",
    locationName: "locationName",
    geoPoint: GeoPoint(0, 0),
    maxMember: 10,
    member: [],
    name: "test Event",
    owner: FirebaseFirestore.instance.collection("users").doc("_test"),
    startTime: DateTime.now(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InputField(
              icon: Icon(Icons.search),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      DateSearchFilter(controller: SearchFilterController()),
                      CategorySearchFilter(
                          controller: SearchFilterController()),
                      DistanceSearchFilter(
                          controller: SearchFilterController()),
                      TypeSearchFilter(controller: SearchFilterController()),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [SearchEventCard(event: event)],
            )
          ],
        ),
      ),
    );
  }
}
