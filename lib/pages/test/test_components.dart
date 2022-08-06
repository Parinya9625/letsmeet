import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/all.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';

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
  Chat chat = Chat(
    by: FirebaseFirestore.instance.collection("users").doc("_test"),
    id: "",
    // image: ["https://picsum.photos/200?image=222"],
    image: [],
    sendTime: DateTime.now(),
    text: "Sample Text",
    isAlert: false,
  );
  User user = User(
    id: "_test",
    bio: "bio",
    birthday: DateTime.now(),
    createdTime: DateTime.now(),
    favCategory: [],
    image: "https://picsum.photos/200?image=21",
    name: "name",
    rating: UserRating(),
    recentView: [],
    role: FirebaseFirestore.instance.collection("roles").doc("user"),
    surname: "surname",
    isFinishSetup: true,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        runSpacing: 8,
        children: [
          ContinueWithGoogleButton(onPressed: () {}),
          ImageCoverPicker(controller: ImagePickerController()),
          InterestCategorySelector(
              controller: InterestCategorySelectorController()),
          NoConnectionBanner(onPressed: () {}),
          const NoEventBanner(),
          const NoSearchResultBanner(),
          SearchEventCard(event: event),
          const TextField(
            decoration: InputDecoration(hintText: "Enter text..."),
          ),
          ChatBubble(by: user, chat: chat, isSender: true),
          ChatBubble(by: user, chat: chat),
          ChatGroupCard(event: event, lastChat: chat, onPressed: () {}),
          CheckboxTile(controller: CheckboxTileController()),
          AdminEventCard(event: event),
          ReviewUserCard(controller: ReviewUserController(), user: user),
          SearchUserCard(user: user),
          Shimmer(
            child: ShimmerLoading(
              isLoading: true,
              placeholder: Container(
                width: double.infinity,
                height: 32,
                color: Colors.black,
              ),
              builder: (context) {
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
