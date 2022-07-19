import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:letsmeet/components/all.dart';
import 'package:letsmeet/components/review_user_card.dart';

import '../models/user.dart';

class reviewUserPage extends StatefulWidget {
  const reviewUserPage({Key? key}) : super(key: key);

  @override
  State<reviewUserPage> createState() => _reviewUserPageState();
}

class _reviewUserPageState extends State<reviewUserPage> {
  User user = User.create(
    birthday: DateTime.now(),
    image:
        "https://avatars.dicebear.com/api/identicon/test.png?size=64&backgroundColor=white",
    name: "name",
    surname: "surname",
    createdTime: DateTime.now(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.done))],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(children: [
          ReviewUserCard(controller: ReviewUserController(), user: user),
          ReviewUserCard(controller: ReviewUserController(), user: user),
          ReviewUserCard(controller: ReviewUserController(), user: user),
          ReviewUserCard(controller: ReviewUserController(), user: user),
          ReviewUserCard(controller: ReviewUserController(), user: user)
        ]),
      ),
    );
  }
}
