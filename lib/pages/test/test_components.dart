import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/all.dart';
import 'package:letsmeet/models/event.dart';

class ComponentsPage extends StatefulWidget {
  const ComponentsPage({Key? key}) : super(key: key);

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  Event event = Event.createOnline(
    ageRestrict: true,
    category: FirebaseFirestore.instance
        .collection("categories")
        .doc("WC01sE2pnNgPUcxdqW7Y"),
    description: "description",
    image: "https://picsum.photos/200?image=12",
    link: "https://google.com",
    maxMember: 10,
    member: [],
    name: "name",
    owner: FirebaseFirestore.instance.collection("users").doc("_test"),
    startTime: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        runSpacing: 8,
        children: [
          ContinueWithGoogleButton(onPressed: () {}),
          ImageCoverPicker(controller: ImageCoverPickerController()),
          InterestCategorySelector(
              controller: InterestCategorySelectorController()),
          NoConnectionBanner(
            onPressed: () {},
          ),
          const NoEventBanner(),
          const NoSearchResultBanner(),
          SearchEventCard(event: event),
          const TextField(
            decoration: InputDecoration(hintText: "Enter text..."),
          ).withElevation(),
        ],
      ),
    );
  }
}
