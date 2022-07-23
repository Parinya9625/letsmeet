import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/models/ban.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TestFirestore extends StatefulWidget {
  const TestFirestore({Key? key}) : super(key: key);

  @override
  State<TestFirestore> createState() => _TestFirestoreState();
}

class _TestFirestoreState extends State<TestFirestore>
    with SingleTickerProviderStateMixin {
  List<String> tabText = [
    "USERS",
    "EVENTS",
    "BANS",
    "REPORTS",
    "CATEGORIES",
    "ROLES",
  ];
  TabController? _tabController;
  int tabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(
        initialIndex: tabIndex, length: tabText.length, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        tabIndex = _tabController!.index;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing Firestore"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            for (String text in tabText) Tab(text: text),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          userPage(context),
          eventPage(context),
          banPage(context),
          reportPage(context),
          categoryPage(context),
          rolePage(context),
        ],
      ),
    );
  }

  String userRemoveDropdown = "";
  String userRecentEventDropdown = "";
  Widget userPage(BuildContext context) {
    List<User> listUser = context.watch<List<User>>();
    if (userRemoveDropdown == "" && listUser.isNotEmpty) {
      userRemoveDropdown = listUser.first.id!;
    }
    List<Event> listEvent = context.watch<List<Event>>();
    if (userRecentEventDropdown == "" && listEvent.isNotEmpty) {
      userRecentEventDropdown = listEvent.first.id!;
    }

    User testUser = User(
      id: "_test",
      bio: "bio",
      birthday: DateTime.now(),
      createdTime: DateTime.now(),
      favCategory: [],
      image: "https://picsum.photos/200?image=69",
      name: "Test",
      rating: UserRating(),
      recentView: [],
      role: FirebaseFirestore.instance.collection("roles").doc("user"),
      surname: "User",
      isFinishSetup: true,
    );
    User testUser2 = User(
      id: "_test",
      bio: "bio",
      birthday: DateTime.now(),
      createdTime: DateTime.now(),
      favCategory: [],
      image: "https://picsum.photos/200?image=420",
      name: "Test User",
      rating: UserRating(),
      recentView: [],
      role: FirebaseFirestore.instance.collection("roles").doc("user"),
      surname: "(Update)",
      isFinishSetup: true,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .addUser(user: testUser);
                              });
                            },
                            child: const Text("Add")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .updateUser(
                                        id: testUser2.id!,
                                        data: testUser2.toMap());
                              });
                            },
                            child: const Text("Update")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: userRemoveDropdown,
                          isExpanded: true,
                          items: [
                            for (User user in listUser) ...{
                              DropdownMenuItem(
                                value: user.id,
                                child: Text("${user.name} ${user.surname}"),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              userRemoveDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .removeUser(id: userRemoveDropdown);
                              userRemoveDropdown = "";
                            });
                          },
                          child: const Text("Remove")),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: userRecentEventDropdown,
                          isExpanded: true,
                          items: [
                            for (Event event in listEvent) ...{
                              DropdownMenuItem(
                                value: event.id,
                                child: Text(event.name),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              userRecentEventDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .addUserRecentView(
                                      user: testUser,
                                      eventId: listEvent
                                          .where((e) =>
                                              e.id == userRecentEventDropdown)
                                          .toList()
                                          .first
                                          .id!);
                            });
                          },
                          child: const Text("Add recent view")),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (User user in context.watch<List<User>>()) ...{
                    FutureBuilder(
                      future: Future.wait([
                        user.getFavCategory,
                        user.getRecentView,
                        user.getRole
                      ]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        List<Category> favCategory = snapshot.data[0];
                        List<Event> recentView = snapshot.data[1];
                        Role role = snapshot.data[2];

                        return ExpansionTile(
                          title: Text("${user.name} ${user.surname}"),
                          children: [
                            ListTile(title: Text("id : ${user.id}")),
                            ListTile(
                                title:
                                    Text("createdTime : ${user.createdTime}")),
                            ListTile(
                              title: Text("image : ${user.image}"),
                              leading: CachedNetworkImage(
                                imageUrl: user.image,
                                width: 64,
                                height: 64,
                              ),
                            ),
                            ListTile(title: Text("name: ${user.name}")),
                            ListTile(title: Text("surname : ${user.surname}")),
                            ListTile(title: Text("role : ${role.name}")),
                            ListTile(title: Text("bio : ${user.bio}")),
                            ListTile(
                                title: Text("birthday : ${user.birthday}")),
                            ListTile(
                                title: Text(
                                    "favCategory : ${favCategory.map((c) => c.name).toList()}")),
                            ListTile(title: Text("rating : ${user.rating}")),
                            ListTile(
                                title: Text(
                                    "recentView : ${recentView.map((e) => e.name).toList()}")),
                          ],
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String eventRemoveDropdown = "";
  Widget eventPage(BuildContext context) {
    List<Event> listEvent = context.watch<List<Event>>();
    if (eventRemoveDropdown == "" && listEvent.isNotEmpty) {
      for (int i = 0; i < listEvent.length; i++) {
        try {
          eventRemoveDropdown = listEvent[i].id!;
          break;
        } catch (e) {
          continue;
        }
      }
    }

    Event testEventIP = Event(
      id: "_test",
      ageRestrict: false,
      category: FirebaseFirestore.instance
          .collection("categories")
          .doc("KVSJjRu4AchyfXY2FNLO"),
      createdTime: DateTime.now(),
      description: "This is a test event",
      image: "https://picsum.photos/200?image=123",
      location: EventLocation(
        name: "In person event !",
        geoPoint: const GeoPoint(1, 2),
      ),
      maxMember: 20,
      member: [],
      memberReviewed: [],
      name: "Test Event",
      owner: FirebaseFirestore.instance.collection("users").doc("_test"),
      startTime: DateTime.now(),
      type: "In Person",
    );
    Event testEventIP2 = Event(
      id: "_test",
      ageRestrict: false,
      category: FirebaseFirestore.instance
          .collection("categories")
          .doc("KVSJjRu4AchyfXY2FNLO"),
      createdTime: DateTime.now(),
      description: "Update event !",
      image: "https://picsum.photos/200?image=456",
      location: EventLocation(
        name: "name update",
        link: "https://google.com",
      ),
      maxMember: 20,
      member: [],
      memberReviewed: [],
      name: "Test Event with update",
      owner: FirebaseFirestore.instance.collection("users").doc("_test"),
      startTime: DateTime.now(),
      type: "Online",
    );
    User testUser = User(
      id: "_test",
      bio: "bio",
      birthday: DateTime.now(),
      createdTime: DateTime.now(),
      favCategory: [],
      image: "https://picsum.photos/200?image=69",
      name: "Test",
      rating: UserRating(),
      recentView: [],
      role: FirebaseFirestore.instance.collection("roles").doc("user"),
      surname: "User",
      isFinishSetup: true,
    );

    TextEditingController _chat = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .addEvent(event: testEventIP);
                              });
                            },
                            child: const Text("Add Event")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .updateEvent(
                                        id: testEventIP2.id!,
                                        data: testEventIP2.toMap());
                              });
                            },
                            child: const Text("Update Event")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: eventRemoveDropdown,
                          isExpanded: true,
                          items: [
                            for (Event event in listEvent) ...{
                              DropdownMenuItem(
                                value: event.id,
                                child: Text(event.name),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              eventRemoveDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .removeEvent(id: eventRemoveDropdown);
                              eventRemoveDropdown = "";
                            });
                          },
                          child: const Text("Remove Event")),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .addEventMember(
                                        event: testEventIP, user: testUser);
                              });
                            },
                            child: const Text("Add member")),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .removeEventMember(
                                        event: testEventIP2, user: testUser);
                              });
                            },
                            child: const Text("Remove member")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .addEventMemberReview(
                                        event: testEventIP, user: testUser);
                              });
                            },
                            child: const Text("Add member review")),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // context
                                //     .read<CloudFirestoreService>()
                                //     .removeEventMemberReview(
                                //         event: testEventIP2, user: testUser);
                              });
                            },
                            child: const Text("Remove member review")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  TextField(
                    controller: _chat,
                    decoration: const InputDecoration(
                        hintText: "Type message... / Chat ID"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context.read<CloudFirestoreService>().addChat(
                                    eventId: testEventIP.id!,
                                    chat: Chat.create(
                                        by: testUser.toDocRef(),
                                        image: [],
                                        text: _chat.text.trim()));
                              });
                            },
                            child: const Text("Send text")),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context.read<CloudFirestoreService>().addChat(
                                    eventId: testEventIP.id!,
                                    chat: Chat.createAlert(
                                        text: _chat.text.trim()));
                              });
                            },
                            child: const Text("Send alert")),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .removeChat(
                                        eventId: testEventIP.id!,
                                        chatId: _chat.text.trim());
                              });
                            },
                            child: const Text("Remove chat")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (Event event in listEvent) ...{
                    FutureBuilder(
                      future: Future.wait([
                        event.getCategory,
                        event.getMember,
                        event.getMemberReviewed,
                        event.getOwner,
                      ]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        Category category = snapshot.data[0];
                        List<User> member = snapshot.data[1];
                        List<User> memberReviewed = snapshot.data[2];
                        User owner = snapshot.data[3];

                        return ExpansionTile(
                          title: Text(event.name),
                          children: [
                            ExpansionTile(
                              title: const Text(
                                "Chats",
                                style: TextStyle(color: Colors.red),
                              ),
                              children: [
                                eventChat(event),
                              ],
                            ),
                            ListTile(title: Text("id : ${event.id}")),
                            ListTile(
                                title:
                                    Text("createdTime : ${event.createdTime}")),
                            ListTile(title: Text("owner : ${owner.id}")),
                            ListTile(
                              title: Text("image : ${event.image}"),
                              leading: CachedNetworkImage(
                                imageUrl: event.image,
                                width: 64,
                                height: 64,
                              ),
                            ),
                            ListTile(title: Text("name : ${event.name}")),
                            ListTile(
                                title:
                                    Text("description : ${event.description}")),
                            ListTile(
                              title: Text("category : ${category.name}"),
                              leading: Icon(category.icon),
                            ),
                            ListTile(
                                title:
                                    Text("ageRestrict : ${event.ageRestrict}")),
                            ListTile(
                                title: Text("location : ${event.location}")),
                            ListTile(
                                title: Text("startTime : ${event.startTime}")),
                            ListTile(
                                title: Text("maxMember : ${event.maxMember}")),
                            ListTile(title: Text("type : ${event.type}")),
                            ListTile(
                                title: Text(
                                    "member : ${member.map((m) => m.id)}")),
                            ListTile(
                                title: Text(
                                    "memberReviewed : ${memberReviewed.map((m) => m.id)}")),
                          ],
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget eventChat(Event event) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("events")
          .doc(event.id)
          .collection("chats")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator.adaptive();
        } else {
          List<DocumentSnapshot> listChatSnap =
              List<DocumentSnapshot>.from(snapshot.data.docs);
          List<Chat> listChat =
              listChatSnap.map((doc) => Chat.fromFirestore(doc: doc)).toList();
          return Column(
            children: [
              for (Chat chat in listChat) ...{
                if (chat.by != null) ...{
                  FutureBuilder(
                    future: Future.wait([chat.getBy]),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator.adaptive();
                      }

                      User user = snapshot.data[0];

                      return ListTile(
                        title: Text(chat.text.toString()),
                        subtitle: Text("${user.name} ${user.surname}"),
                      );
                    },
                  ),
                } else ...{
                  ListTile(
                    title: Text(chat.text.toString()),
                    subtitle: Text("Chat Alert"),
                  ),
                }
              }
            ],
          );
        }
      },
    );
  }

  String banAddDropdown = "";
  String banRemoveDropdown = "";
  Widget banPage(BuildContext context) {
    List<User> listUser = context.watch<List<User>>();
    if (banAddDropdown == "" && listUser.isNotEmpty) {
      banAddDropdown = listUser.first.id!;
    }
    List<Ban> listBan = context.watch<List<Ban>>();
    if (banRemoveDropdown == "" && listBan.isNotEmpty) {
      banRemoveDropdown = listBan.first.id;
    }

    TextEditingController _reason = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: banAddDropdown,
                          isExpanded: true,
                          items: [
                            for (User user in listUser) ...{
                              DropdownMenuItem(
                                value: user.id,
                                child: Text("${user.name} ${user.surname}"),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              banAddDropdown = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _reason,
                    decoration: const InputDecoration(hintText: "reason"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context.read<CloudFirestoreService>().addBan(
                                        ban: Ban.now(
                                      id: banAddDropdown,
                                      reason: _reason.text.trim(),
                                    ));
                                banAddDropdown = "";
                              });
                            },
                            child: const Text("Add")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: banRemoveDropdown,
                          isExpanded: true,
                          items: [
                            for (Ban ban in listBan) ...{
                              DropdownMenuItem(
                                value: ban.id,
                                child: Text(ban.id),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              banRemoveDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .removeBan(id: banRemoveDropdown);
                              banRemoveDropdown = "";
                            });
                          },
                          child: const Text("Remove")),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (Ban ban in listBan) ...{
                    FutureBuilder(
                      future: Future.wait([]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        return ExpansionTile(
                          title: Text(ban.id),
                          children: [
                            ListTile(title: Text("id : ${ban.id}")),
                            ListTile(title: Text("banTime : ${ban.banTime}")),
                            ListTile(title: Text("reason : ${ban.reason}")),
                          ],
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String reportRemoveDropdown = "";
  Widget reportPage(BuildContext context) {
    List<Report> listReport = context.watch<List<Report>>();
    if (reportRemoveDropdown == "" && listReport.isNotEmpty) {
      reportRemoveDropdown = listReport.first.id;
    }

    TextEditingController _id = TextEditingController();
    TextEditingController _type = TextEditingController();
    TextEditingController _reason = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _id,
                    decoration: const InputDecoration(hintText: "ID"),
                  ),
                  TextField(
                    controller: _reason,
                    decoration: const InputDecoration(hintText: "Reason"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context.read<CloudFirestoreService>().addReport(
                                    report: Report.user(
                                        id: _id.text.trim(),
                                        reason: _reason.text.trim()));
                              });
                            },
                            child: const Text("Add user")),
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context.read<CloudFirestoreService>().addReport(
                                    report: Report.event(
                                        id: _id.text.trim(),
                                        reason: _reason.text.trim()));
                              });
                            },
                            child: const Text("Add event")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: reportRemoveDropdown,
                          isExpanded: true,
                          items: [
                            for (Report report in listReport) ...{
                              DropdownMenuItem(
                                value: report.id,
                                child: Text(report.id),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              reportRemoveDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .removeReport(id: reportRemoveDropdown);
                              reportRemoveDropdown = "";
                            });
                          },
                          child: const Text("Remove")),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (Report report in listReport) ...{
                    FutureBuilder(
                      future: Future.wait([]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        return ExpansionTile(
                          title: Text(report.id),
                          children: [
                            ListTile(title: Text("id : ${report.id}")),
                            ListTile(title: Text("type : ${report.type}")),
                            ListTile(title: Text("count : ${report.count}")),
                            ListTile(title: Text("reason : ${report.reason}")),
                          ],
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String categoryRemoveDropdown = "";
  Widget categoryPage(BuildContext context) {
    List<Category> listCategory = context.watch<List<Category>>();
    if (categoryRemoveDropdown == "" && listCategory.isNotEmpty) {
      categoryRemoveDropdown = listCategory.first.id!;
    }

    Category testCategory = Category(
      id: "_test",
      name: "TEST",
      icon: Icons.face,
    );
    Category testCategory2 = Category(
      id: "_test",
      name: "TEST (Update)",
      icon: Icons.face_retouching_natural,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .addCategory(category: testCategory);
                              });
                            },
                            child: const Text("Add")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .updateCategory(
                                        id: testCategory2.id!,
                                        data: testCategory2.toMap());
                              });
                            },
                            child: const Text("Update")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: categoryRemoveDropdown,
                          isExpanded: true,
                          items: [
                            for (Category category in listCategory) ...{
                              DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              categoryRemoveDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .removeCategory(id: categoryRemoveDropdown);
                              categoryRemoveDropdown = "";
                            });
                          },
                          child: const Text("Remove")),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (Category category in listCategory) ...{
                    FutureBuilder(
                      future: Future.wait([]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        return ExpansionTile(
                          leading: Icon(category.icon),
                          title: Text(category.name),
                          children: [
                            ListTile(title: Text("id : ${category.id}")),
                            ListTile(title: Text("name : ${category.name}")),
                            ListTile(
                                title: Text(
                                    "iconData: ${category.icon.codePoint} ${category.icon.fontFamily} ${category.icon.fontPackage}")),
                          ],
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String roleRemoveDropdown = "";
  Widget rolePage(BuildContext context) {
    List<Role> listRole = context.watch<List<Role>>();
    if (roleRemoveDropdown == "" && listRole.isNotEmpty) {
      roleRemoveDropdown = listRole.first.id!;
    }

    Role testRole = Role(
      id: "_test",
      name: "TEST",
      backgroundColor: Colors.greenAccent,
      foregroundColor: Colors.white,
      permission: UserPermission(),
    );
    Role testRole2 = Role(
      id: "_test",
      name: "TEST (Update)",
      backgroundColor: Colors.purpleAccent,
      foregroundColor: Colors.white,
      permission: UserPermission(),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .addRole(role: testRole);
                              });
                            },
                            child: const Text("Add")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                context
                                    .read<CloudFirestoreService>()
                                    .updateRole(
                                        id: testRole2.id!,
                                        data: testRole2.toMap());
                              });
                            },
                            child: const Text("Update")),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: roleRemoveDropdown,
                          isExpanded: true,
                          items: [
                            for (Role role in listRole) ...{
                              DropdownMenuItem(
                                value: role.id,
                                child: Text(role.name),
                              ),
                            }
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              roleRemoveDropdown = value!;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              context
                                  .read<CloudFirestoreService>()
                                  .removeRole(id: roleRemoveDropdown);
                              roleRemoveDropdown = "";
                            });
                          },
                          child: const Text("Remove")),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (Role role in listRole) ...{
                    FutureBuilder(
                      future: Future.wait([]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        return ExpansionTile(
                          leading: Material(
                            elevation: 4,
                            child: Container(
                              color: role.backgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Text(
                                  role.name,
                                  style: TextStyle(
                                    color: role.foregroundColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: Text(role.name),
                          children: [
                            ListTile(title: Text("id : ${role.id}")),
                            ListTile(title: Text("name : ${role.name}")),
                            ListTile(
                                leading: Material(
                                  elevation: 4,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    color: role.foregroundColor,
                                    child: const Text(" "),
                                  ),
                                ),
                                title: Text(
                                    "foregroundColor : ${role.foregroundColor.red} ${role.foregroundColor.green} ${role.foregroundColor.blue} ${role.foregroundColor.opacity}")),
                            ListTile(
                                leading: Material(
                                  elevation: 4,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    color: role.backgroundColor,
                                    child: const Text(" "),
                                  ),
                                ),
                                title: Text(
                                    "backgroundColor : ${role.backgroundColor.red} ${role.backgroundColor.green} ${role.backgroundColor.blue} ${role.backgroundColor.opacity}")),
                            ListTile(
                                title: Text("permission : ${role.permission}")),
                          ],
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
