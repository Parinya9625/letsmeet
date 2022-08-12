import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/chat_group_card.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/components/no_group_chat_banner.dart';
import 'package:letsmeet/components/no_search_result_banner.dart';
import 'package:provider/provider.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/chat.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchBarNode = FocusNode();
  // popup menu option
  bool _isHideEndedEvent = true;

  Widget placeholder() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 1,
            ),
            child: Container(
              height: 60 + 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
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

  Widget chatsPopupMenu() {
    GlobalKey<PopupMenuButtonState<String>> popupMenuKey = GlobalKey();

    return PopupMenuButton(
      key: popupMenuKey,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        popupMenuItem(
          icons: _isHideEndedEvent
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          title: _isHideEndedEvent ? "Hide ended event" : "Show ended event",
        ),
      ],
      onSelected: (selected) {
        switch (selected) {
          case "Show ended event":
          case "Hide ended event":
            setState(() {
              _isHideEndedEvent = !_isHideEndedEvent;
            });
            break;
        }
      },
      child: IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: Theme.of(context).textTheme.headlineLarge!.color,
          ),
          onPressed: () {
            popupMenuKey.currentState!.showButtonMenu();
          }),
    );
  }

  List<Widget> topSection() {
    return [
      Padding(
          padding: const EdgeInsets.only(
            left: 32,
            right: 16,
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                "Chats",
                style: Theme.of(context).textTheme.headlineLarge,
              )),
              chatsPopupMenu(),
            ],
          )),
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
        ),
        child: InputField(
          controller: searchController,
          focusNode: searchBarNode,
          icon: const Icon(
            Icons.search_rounded,
          ),
          hintText: "Search by event name",
          onChanged: (String value) {
            setState(() {});
          },
          onClear: () {
            setState(() {});
          },
        ),
      ).horizontalPadding(),
    ];
  }

  Widget chatSection(User? user) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () {
          setState(() {});

          return Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        },
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("events")
                  .where(
                    "member",
                    arrayContains: user?.toDocRef(),
                  )
                  .orderBy(
                    "startTime",
                  )
                  .snapshots()
                  .map((events) => events.docs
                      .map((doc) => Event.fromFirestore(
                            doc: doc,
                          ))
                      .toList()),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ShimmerLoading(
                  isLoading: !snapshot.hasData,
                  placeholder: Wrap(
                    runSpacing: 8,
                    children: [
                      placeholder(),
                    ],
                  ).horizontalPadding(),
                  builder: (BuildContext context) {
                    List<Event> listEvent = snapshot.data;

                    // hide ended event
                    if (_isHideEndedEvent) {
                      listEvent = listEvent
                          .where((event) => !event.startTime
                              .difference(DateTime.now().subtract(
                                // Add 3 more day before hide
                                const Duration(days: 3),
                              ))
                              .isNegative)
                          .toList();
                    }

                    // search by event name
                    if (searchController.text.isNotEmpty) {
                      listEvent = listEvent
                          .where((event) => event.name.toLowerCase().contains(
                              searchController.text.toLowerCase().trim()))
                          .toList();
                    }

                    // empty group chat
                    if (listEvent.isEmpty) {
                      return Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          child: searchController.text.isNotEmpty
                              ? const NoSearchResultBanner()
                              : const NoGroupChatBanner(),
                        ),
                      );
                    }

                    return Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16 + kBottomNavigationBarHeight,
                          ),
                          child: Wrap(
                            runSpacing: 8,
                            children: [
                              ...listEvent.map((event) {
                                return StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("events")
                                        .doc(event.id)
                                        .collection("chats")
                                        .orderBy(
                                          "sendTime",
                                          descending: true,
                                        )
                                        .limit(1)
                                        .snapshots()
                                        .map((chats) => chats.docs
                                            .map((doc) => Chat.fromFirestore(
                                                  doc: doc,
                                                ))
                                            .toList()),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      return ShimmerLoading(
                                        isLoading: !snapshot.hasData,
                                        placeholder: placeholder(),
                                        builder: (BuildContext context) {
                                          Chat? chat = snapshot.data.isNotEmpty
                                              ? snapshot.data.first
                                              : null;

                                          return ChatGroupCard(
                                            event: event,
                                            lastChat: chat,
                                            onPressed: () {
                                              context
                                                  .read<
                                                      GlobalKey<
                                                          NavigatorState>>()
                                                  .currentState!
                                                  .pushNamed(
                                                    "/event/chat",
                                                    arguments: event,
                                                  );
                                            },
                                          );
                                        },
                                      );
                                    });
                              }).toList(),
                              SizedBox(
                                height: 32,
                                child: Container(),
                              ),
                            ],
                          ).horizontalPadding(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.read<User?>();

    return GestureDetector(
      onTap: () {
        searchBarNode.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...topSection(),
                chatSection(user),
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
