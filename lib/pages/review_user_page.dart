import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/review_user_controller.dart';
import 'package:letsmeet/components/review_user_card.dart';
import 'package:letsmeet/components/review_user_empty_banner.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:provider/provider.dart';

class ReviewUserPage extends StatefulWidget {
  final Event event;
  const ReviewUserPage({Key? key, required this.event}) : super(key: key);

  @override
  State<ReviewUserPage> createState() => _ReviewUserPageState();
}

class _ReviewUserPageState extends State<ReviewUserPage> {
  Map<String, ReviewUserController> reviewsController = {};

  Widget placeholder() {
    return AspectRatio(
      aspectRatio: 4 / 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  void initState() {
    User user = context.read<User?>()!;

    List<dynamic> listMember = widget.event.member;
    listMember.removeWhere((member) => member.id == user.id);

    for (var member in listMember) {
      reviewsController[member.id] = ReviewUserController();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            onPressed: () {
              context.read<CloudFirestoreService>().addEventMemberReview(
                  event: widget.event, user: context.read<User?>()!);

              reviewsController.forEach((userId, controller) {
                if (controller.value != 0) {
                  context
                      .read<CloudFirestoreService>()
                      .reviewUser(id: userId, rating: controller.value);
                }
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: reviewsController.isEmpty
            ? const ReviewUserEmptyBanner()
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: FutureBuilder(
                  future: Future.wait([widget.event.getMember]),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ShimmerLoading(
                      isLoading: !snapshot.hasData,
                      placeholder: Wrap(
                        runSpacing: 16,
                        children: [
                          placeholder(),
                          placeholder(),
                          placeholder(),
                          placeholder(),
                          placeholder(),
                        ],
                      ),
                      builder: (BuildContext context) {
                        List<User> listUser = snapshot.data[0];

                        return Wrap(
                          runSpacing: 16,
                          children: listUser
                              .map(
                                (user) => ReviewUserCard(
                                  controller: reviewsController[user.id]!,
                                  user: user,
                                ),
                              )
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
