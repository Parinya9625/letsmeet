import 'package:flutter/material.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/components/event_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget eventCard(Event event) {
    return EventCard(
        isSmall: true,
        event: event,
        onPressed: () {
          context
              .read<GlobalKey<NavigatorState>>()
              .currentState!
              .pushNamed("/event", arguments: event);

          context.read<CloudFirestoreService>().addUserRecentView(
                user: context.read<User?>()!,
                eventId: event.id!,
              );
        });
  }

  Widget headerPlaceholder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget eventPlaceholder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 192,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
        ).horizontalPadding(),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 16,
            children: [
              const SizedBox(width: 16),
              for (int i = 0; i < 2; i++) ...{
                SizedBox(
                  height: 160,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              },
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget upcomingEvents(User user) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("events")
            .where("member", arrayContains: user.toDocRef())
            .where("startTime", isGreaterThanOrEqualTo: DateTime.now())
            .orderBy("startTime")
            .get()
            .then((list) {
          return list.docs.map((doc) => Event.fromFirestore(doc: doc)).toList();
        }),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ShimmerLoading(
            isLoading: !snapshot.hasData,
            placeholder: eventPlaceholder(),
            builder: (BuildContext context) {
              List<Event> listEvent = snapshot.data;

              if (listEvent.isEmpty) {
                return const SizedBox();
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Upcoming Events",
                    style: Theme.of(context).textTheme.headline1,
                  ).horizontalPadding(),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 16,
                      children: [
                        const SizedBox(width: 16),
                        ...listEvent.map((event) {
                          return EventCard(
                              isSmall: true,
                              event: event,
                              onPressed: () {
                                context
                                    .read<GlobalKey<NavigatorState>>()
                                    .currentState!
                                    .pushNamed("/event", arguments: event);
                              });
                        }).toList(),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  Widget recentViewEvents(User user) {
    if (user.recentView.isNotEmpty) {
      return FutureBuilder(
          future: user.getRecentView,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return ShimmerLoading(
              isLoading: !snapshot.hasData,
              placeholder: eventPlaceholder(),
              builder: (BuildContext context) {
                List<Event> listEvent = snapshot.data;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recently Viewed",
                      style: Theme.of(context).textTheme.headline1,
                    ).horizontalPadding(),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 16,
                        children: [
                          const SizedBox(width: 16),
                          ...listEvent.map((event) {
                            return EventCard(
                                isSmall: true,
                                event: event,
                                onPressed: () {
                                  context
                                      .read<GlobalKey<NavigatorState>>()
                                      .currentState!
                                      .pushNamed("/event", arguments: event);
                                });
                          }).toList(),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          });
    }
    return const SizedBox();
  }

  Widget eventSection(Category category) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("events")
            .where("category", isEqualTo: category.toDocRef())
            .orderBy(
              "createdTime",
              descending: true,
            )
            .limit(10)
            .get()
            .then((list) {
          return list.docs.map((doc) => Event.fromFirestore(doc: doc)).toList();
        }),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ShimmerLoading(
            isLoading: !snapshot.hasData,
            placeholder: eventPlaceholder(),
            builder: (BuildContext context) {
              List<Event> listEvent = snapshot.data;

              if (listEvent.isEmpty) {
                return const SizedBox();
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {
                        // TODO: Add click function
                        print("MORE of ${category.name}");
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            color: Theme.of(context).textTheme.headline1!.color,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.headline1,
                          )),
                          Text(
                            "More",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      )).horizontalPadding(),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 16,
                      children: [
                        const SizedBox(width: 16),
                        ...listEvent.map((event) {
                          return eventCard(event);
                        }).toList(),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.read<User?>();
    List<Category> allCategory = context.watch<List<Category>>();

    List<Category> favCategory = user != null
        ? allCategory
            .where((category) => user.favCategory.contains(category.toDocRef()))
            .toList()
        : [];

    List<Category> notFavCategory = user != null
        ? allCategory
            .where(
                (category) => !user.favCategory.contains(category.toDocRef()))
            .toList()
        : allCategory;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 96,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        flexibleSpace: SafeArea(
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, "/profile");
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: user.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: user.image,
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                              )
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${user.name} ${user.surname}",
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder(
                            future: user.getRole,
                            builder:
                                (BuildContext contex, AsyncSnapshot snapshot) {
                              return ShimmerLoading(
                                isLoading: !snapshot.hasData,
                                placeholder: Container(
                                  width: 64,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.black,
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  Role role = snapshot.data;

                                  return Badge(
                                    title: role.name,
                                    backgroundColor: role.backgroundColor,
                                    foregroundColor: role.foregroundColor,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {});

          return Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 32,
              bottom: 48,
            ),
            child: Wrap(
              runSpacing: 32,
              children: [
                upcomingEvents(user),
                recentViewEvents(user),
                Text(
                  "Explore New Events",
                  style: Theme.of(context).textTheme.headline1,
                ).horizontalPadding(),
                ...favCategory
                    .map((category) => eventSection(category))
                    .toList(),
                ...notFavCategory
                    .map((category) => eventSection(category))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension PaddingEx on Widget {
  Widget horizontalPadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: this,
    );
  }
}
