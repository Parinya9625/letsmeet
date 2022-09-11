import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/event_card.dart';
import 'package:letsmeet/components/no_event_banner.dart';
import 'package:letsmeet/components/profile_header.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:provider/provider.dart';

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
  int myEventsAmount = 0;
  int joinedEventsAmount = 0;
  List<Tab> tabName = [];
  TabController? tabController;
  late User user;

  @override
  void initState() {
    updateTabName();

    tabController =
        TabController(initialIndex: 0, length: tabName.length, vsync: this);

    super.initState();
  }

  void updateTabName() {
    tabName = [
      Tab(text: "My Events ($myEventsAmount)"),
      Tab(text: "Joined Events ($joinedEventsAmount)"),
    ];
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
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 16,
                  right: 16,
                  bottom: 32 + kBottomNavigationBarHeight,
                ),
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
                              context
                                  .read<GlobalKey<NavigatorState>>()
                                  .currentState!
                                  .pushNamed("/event", arguments: event);
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

  List<String> reportOption = [
    "Suspicious or spam",
    "They're pretending to be me or someone else",
    "Often create fake event",
  ]..sort();

  Future<void> showReportDialog() {
    int? selectedReport;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Report user"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: selectedReport != null
                      ? () {
                          context.read<CloudFirestoreService>().addReport(
                                report: Report.user(
                                  id: user.id!,
                                  reason: reportOption[selectedReport!],
                                ),
                              );
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text("Submit"),
                ),
              ],
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < reportOption.length; i++) ...{
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Radio<int>(
                        value: i,
                        groupValue: selectedReport,
                        onChanged: (int? value) {
                          setState(() {
                            selectedReport = value;
                          });
                        },
                      ),
                      title: Text(
                        reportOption[i],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headline1!.color,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedReport = i;
                        });
                      },
                    ),
                  }
                ],
              ),
            );
          },
        );
      },
    );
  }

  PopupMenuItem<String> popupMenuItem(
      {required IconData icons, required String title}) {
    return PopupMenuItem<String>(
      value: title,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icons,
          color: Theme.of(context).textTheme.headline1!.color,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .get()
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            User? globalUser = context.read<User?>();
            if (widget.isOtherUser == false && globalUser != null) {
              // load current user data from provider for better loading time
              user = globalUser;
            } else {
              // wait for loading other user profile
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          } else {
            // Load new user data everytime it refresh
            user = User.fromFirestore(doc: snapshot.data[0]);
          }

          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    pinned: true,
                    expandedHeight: widget.isOtherUser ? 240 : 320,
                    forceElevated: true,
                    actions: [
                      if (widget.isOtherUser) ...{
                        PopupMenuButton(
                          position: PopupMenuPosition.under,
                          itemBuilder: (context) {
                            return [
                              popupMenuItem(
                                icons: Icons.flag_rounded,
                                title: "Report",
                              ),
                            ];
                          },
                          onSelected: (selected) {
                            switch (selected) {
                              case "Report":
                                showReportDialog();
                                break;
                            }
                          },
                        ),
                      },
                    ],
                    title: LayoutBuilder(
                      builder: ((context, constraints) {
                        final FlexibleSpaceBarSettings? settings =
                            context.dependOnInheritedWidgetOfExactType<
                                FlexibleSpaceBarSettings>();

                        // !! ISSUE IN MY Samsung A53 5G DEVICE !!
                        // ?? BUT Samsung S8 WORK FINE ??
                        // Fix : use "minExtend + 1" because device with notch
                        // don't work when use only minExtend.
                        bool isCollapse = settings == null ||
                            settings.currentExtent <= settings.minExtent + 1;

                        return AnimatedOpacity(
                          opacity: isCollapse ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Text("${user.name} ${user.surname}"),
                        );
                      }),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        child: ProfileHeader(
                          user: user,
                          isOtherUser: widget.isOtherUser,
                          onEditPressed: () {
                            context
                                .read<GlobalKey<NavigatorState>>()
                                .currentState!
                                .pushNamed("/profile/edit");
                          },
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
                    (events) {
                      if (myEventsAmount != events.docs.length) {
                        setState(() {
                          myEventsAmount = events.docs.length;
                          updateTabName();
                        });
                      }

                      return events.docs
                          .map((doc) => Event.fromFirestore(doc: doc))
                          .toList();
                    },
                  ),
                ),
                eventTab(
                  id: "joinedEvent",
                  stream: FirebaseFirestore.instance
                      .collection("events")
                      .where("owner", isNotEqualTo: user.toDocRef())
                      .where("member", arrayContains: user.toDocRef())
                      .snapshots()
                      .map(
                    (events) {
                      if (joinedEventsAmount != events.docs.length) {
                        setState(() {
                          joinedEventsAmount = events.docs.length;
                          updateTabName();
                        });
                      }

                      return events.docs
                          .map((doc) => Event.fromFirestore(doc: doc))
                          .toList();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
