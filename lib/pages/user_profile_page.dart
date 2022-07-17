import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/event_card.dart';
import 'package:letsmeet/components/no_event_banner.dart';
import 'package:letsmeet/components/profile_header.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final bool isOtherUser;

  const UserProfilePage({
    Key? key,
    required this.isOtherUser,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  List<Tab> tabName = const [
    Tab(text: "My Events"),
    Tab(text: "Joined Events"),
  ];
  TabController? tabController;
  ScrollController scrollController = ScrollController();
  bool isExpanded = false;
  late User user;

  @override
  void initState() {
    tabController =
        TabController(initialIndex: 0, length: tabName.length, vsync: this);

    // TODO (IF CAN FIX): Performance is to slow with this listen
    scrollController.addListener(() {
      if (scrollController.offset == 216) {
        setState(() {
          isExpanded = true;
        });
      } else if (isExpanded) {
        setState(() {
          isExpanded = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  Widget tabPage({
    required String id,
    required RefreshCallback onRefresh,
    required Widget child,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return RefreshIndicator(
          edgeOffset: 128,
          onRefresh: onRefresh,
          child: CustomScrollView(
            key: PageStorageKey<String>(id),
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverToBoxAdapter(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget placeholder() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget eventTab({
    required String id,
    required Stream<List<Event>> stream,
  }) {
    return tabPage(
      id: id,
      onRefresh: () {
        setState(() {});
        return Future<void>.delayed(const Duration(seconds: 1));
      },
      child: StreamBuilder(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
          return ShimmerLoading(
            isLoading: !snapshot.hasData,
            placeholder: placeholder(),
            builder: (BuildContext context) {
              List<Event> listEvent = snapshot.data!;

              if (listEvent.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: NoEventBanner(
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ...listEvent.map((event) {
                    return FutureBuilder(
                      future: Future.wait([event.getMemberReviewed]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        List<User> memberReviewed = [];
                        if (snapshot.hasData) {
                          memberReviewed = snapshot.data[0];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EventCard(
                            event: event,
                            isReviewed: snapshot.hasData
                                ? memberReviewed
                                    .any((member) => member.id == user.id)
                                : false,
                            onPressed: () {
                              //TODO : Tap Event Card
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                ]),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection("users").doc(widget.userId).get()
      ]),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Load new user data everytime it refresh
        user = User.fromFirestore(doc: snapshot.data[0]);

        return NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  pinned: true,
                  expandedHeight: 320,
                  toolbarHeight: kToolbarHeight,
                  forceElevated: true,
                  title: AnimatedOpacity(
                    opacity: isExpanded ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text("${user.name} ${user.surname}"),
                  ),
                  flexibleSpace: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: FlexibleSpaceBar(
                      background: SafeArea(
                        child: ProfileHeader(
                          user: user,
                          isOtherUser: widget.isOtherUser,
                          onEditPressed: () {
                            // TODO : Add edit profile nav
                          },
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: tabController,
                    tabs: tabName,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController!,
            children: [
              eventTab(
                id: "myEvent",
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .where("owner", isEqualTo: user.toDocRef())
                    .snapshots()
                    .map(
                      (events) => events.docs
                          .map((doc) => Event.fromFirestore(doc: doc))
                          .toList(),
                    ),
              ),
              eventTab(
                id: "joinedEvent",
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .where("member", arrayContains: user.toDocRef())
                    .snapshots()
                    .map(
                      (events) => events.docs
                          .map((doc) => Event.fromFirestore(doc: doc))
                          .toList(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
