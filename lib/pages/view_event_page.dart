// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/all.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/style.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewEventPage extends StatefulWidget {
  final Event event;
  const ViewEventPage({Key? key, required this.event}) : super(key: key);

  @override
  State<ViewEventPage> createState() => _ViewEventPageState();
}

class _ViewEventPageState extends State<ViewEventPage> {
  late Event event;
  Completer<GoogleMapController> mapController = Completer();

  Widget placeholder() {
    return Container(
      width: 100,
      height: 24,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
    );
  }

  Widget avatar({required String url}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        width: 32,
        height: 32,
        imageUrl: url,
        fit: BoxFit.cover,
      ),
    );
  }

  bool isUserOver20() {
    var user = context.read<User?>();
    var now = DateTime.now();
    var ageLimitDay = DateTime(now.year - 20, now.month, now.day);

    return user!.birthday.isBefore(ageLimitDay);
  }

  void joinEvent() async {
    User? user = context.read<User?>();

    showLoading();

    context
        .read<CloudFirestoreService>()
        .addEventMember(event: event, user: user!)
        .then(
      (isSuccess) {
        if (isSuccess) {
          // Alert in group chat
          context.read<CloudFirestoreService>().addChat(
              eventId: widget.event.id!,
              chat: Chat.createAlert(text: "${user.name} joined the event"));
        }

        Navigator.pop(context);
      },
    );
  }

  bool canJoinEvent() {
    return !event.startTime.difference(DateTime.now()).isNegative &&
        event.member.length < event.maxMember &&
        !event.member.any((member) => member.id == context.read<User?>()!.id) &&
        event.owner.id != context.read<User?>()!.id &&
        (!event.ageRestrict || isUserOver20());
  }

  bool canReviewUser() {
    User? user = context.read<User?>();
    return event.member.any((member) => member.id == user!.id) &&
        !event.memberReviewed.any((member) => member.id == user!.id) &&
        DateTime.now().isAfter(event.startTime);
  }

  void showLoading() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }

  void confirmLeaveEvent() async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm leave event"),
          content: const Text("Are you sure you want to leave this event?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text("Leave"),
              onPressed: () async {
                Navigator.pop(dialogContext);

                showLoading();
                await context.read<CloudFirestoreService>().removeEventMember(
                    event: event, user: context.read<User?>()!);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void confirmCloseEvent() async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm close event"),
          content: const Text(
              "Are you sure you want to close this event? This event will be close and delete permanently."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text("Close"),
              onPressed: () async {
                Navigator.pop(dialogContext);

                showLoading();
                await context
                    .read<CloudFirestoreService>()
                    .removeEvent(id: event.id!);

                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void confirmKickMember(User member) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirm kick ${member.name} ${member.surname}"),
          content: Text(
              "Are you sure you want to kick ${member.name} ${member.surname} from this event?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text("Kick"),
              onPressed: () async {
                Navigator.pop(dialogContext);

                showLoading();
                await context
                    .read<CloudFirestoreService>()
                    .removeEventMember(event: event, user: member);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void viewUserProfile(User member) {
    User? user = context.read<User?>();
    context
        .read<GlobalKey<NavigatorState>>()
        .currentState!
        .pushNamed("/profile", arguments: {
      "userId": member.id,
      "isOtherUser": user!.id != member.id,
    });
  }

  void showReportEventDialog() {
    List<String> reportOption = [
      "Fake event",
      "Harassment",
      "Nudity",
      "Spam",
      "Suicide or self-injury",
      "Violence"
    ]..sort();

    int? selectedReport;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Report event"),
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
                                report: Report.event(
                                  id: event.id!,
                                  reason: reportOption[selectedReport!],
                                ),
                              );
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Report submitted",
                              ),
                            ),
                          );
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

  void showReportUserDialog(User member) {
    List<String> reportOption = [
      "Suspicious or spam",
      "They're pretending to be me or someone else",
      "Often create fake event",
    ]..sort();

    int? selectedReport;
    showDialog(
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
                                  id: member.id!,
                                  reason: reportOption[selectedReport!],
                                ),
                              );
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Report ${member.name} ${member.surname} submitted",
                              ),
                            ),
                          );
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

  Widget showOwnerOtherUserMenu(User member) {
    GlobalKey<PopupMenuButtonState<String>> popupMenuKey = GlobalKey();

    return PopupMenuButton(
      key: popupMenuKey,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        popupMenuItem(icons: Icons.person_rounded, title: "View profile"),
        popupMenuItem(icons: Icons.person_remove_rounded, title: "Kick member"),
        popupMenuItem(icons: Icons.flag_rounded, title: "Report"),
      ],
      onSelected: (selected) {
        switch (selected) {
          case "View profile":
            viewUserProfile(member);
            break;
          case "Kick member":
            confirmKickMember(member);
            break;
          case "Report":
            showReportUserDialog(member);
            break;
        }
      },
      child: GestureDetector(
        child: avatar(url: member.image),
        onTap: () {
          popupMenuKey.currentState!.showButtonMenu();
        },
      ),
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
  void initState() {
    event = widget.event;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.read<User?>();

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(widget.event.id)
            .snapshots()
            .map((doc) => Event.fromFirestore(doc: doc)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            event = snapshot.data;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(event.name),
              actions: [
                if (canReviewUser()) ...{
                  IconButton(
                    icon: const Icon(Icons.reviews_rounded),
                    tooltip: "Review user",
                    onPressed: () {
                      context
                          .read<GlobalKey<NavigatorState>>()
                          .currentState!
                          .pushNamed("/event/review", arguments: event);
                    },
                  ),
                },
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.comment),
                  tooltip: "Chat",
                  onPressed: () {
                    context
                        .read<GlobalKey<NavigatorState>>()
                        .currentState!
                        .pushNamed(
                          "/event/chat",
                          arguments: event,
                        );
                  },
                ),
                PopupMenuButton(
                  position: PopupMenuPosition.under,
                  itemBuilder: (context) {
                    return [
                      if (canJoinEvent()) ...{
                        popupMenuItem(
                          icons: Icons.event_available_rounded,
                          title: "Join event",
                        ),
                      },
                      if (event.member.any((member) => member.id == user!.id) &&
                          event.owner.id != user!.id) ...{
                        popupMenuItem(
                          icons: Icons.event_busy_rounded,
                          title: "Leave event",
                        ),
                      },
                      if (event.owner.id == user!.id) ...{
                        if (DateTime.now().isBefore(event.startTime)) ...{
                          popupMenuItem(
                            icons: Icons.edit_calendar_rounded,
                            title: "Edit event",
                          ),
                        },
                        popupMenuItem(
                          icons: Icons.event_busy_rounded,
                          title: "Close event",
                        ),
                      } else ...{
                        popupMenuItem(
                          icons: Icons.flag_rounded,
                          title: "Report",
                        ),
                      },
                    ];
                  },
                  onSelected: (selected) {
                    switch (selected) {
                      case "Join event":
                        joinEvent();
                        break;
                      case "Leave event":
                        confirmLeaveEvent();
                        break;
                      case "Close event":
                        confirmCloseEvent();
                        break;
                      case "Edit event":
                        context
                            .read<GlobalKey<NavigatorState>>()
                            .currentState!
                            .pushNamed("/event/edit", arguments: event);
                        break;
                      case "Report":
                        showReportEventDialog();
                        break;
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: event.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (event.ageRestrict) ...{
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Badge(
                              title: "Over 20+",
                              backgroundColor: Theme.of(context)
                                  .extension<LetsMeetColor>()!
                                  .eventRestrict,
                            ),
                          ),
                        },
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Wrap(
                      runSpacing: 16,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .copyWith(
                                        fontSize: 28,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.category_rounded,
                              color:
                                  Theme.of(context).textTheme.headline1!.color,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Category",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: event.getCategory,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                return ShimmerLoading(
                                  isLoading: !snapshot.hasData,
                                  placeholder: placeholder(),
                                  builder: (BuildContext context) {
                                    Category category = snapshot.data;
                                    return Row(
                                      children: [
                                        Icon(
                                          category.icon,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        if (event.type == "In Person") ...{
                          Row(
                            children: [
                              Icon(
                                Icons.place_rounded,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    "Location",
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                ),
                              ),
                              Text(
                                event.location.name,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: AspectRatio(
                              aspectRatio: 21 / 9,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      event.location.geoPoint!.latitude,
                                      event.location.geoPoint!.longitude),
                                  zoom: 16,
                                ),
                                liteModeEnabled: true,
                                markers: {
                                  Marker(
                                    markerId:
                                        MarkerId(DateTime.now().toString()),
                                    position: LatLng(
                                        event.location.geoPoint!.latitude,
                                        event.location.geoPoint!.longitude),
                                  ),
                                },
                                onMapCreated: (GoogleMapController controller) {
                                  mapController.complete(controller);
                                },
                              ),
                            ),
                          ),
                        },
                        Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: 16,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      "Date & Time",
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat("EEEE, dd MMMM y • HH:mm")
                                  .format(event.startTime),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: 16,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notes_rounded,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      "Detail",
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              event.description,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                        if (event.type == "Online" &&
                            event.member
                                .any((member) => member.id == user!.id)) ...{
                          Wrap(
                            alignment: WrapAlignment.center,
                            runSpacing: 16,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.language_rounded,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        "Link",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (!await launchUrl(
                                      Uri.parse(event.location.link!),
                                      mode: LaunchMode.externalApplication,
                                      webOnlyWindowName: "_blank")) {
                                    // if launch url fail
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Could not launch ${event.location.link}",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  event.location.link!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3!
                                      .copyWith(
                                          decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        },
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              color:
                                  Theme.of(context).textTheme.headline1!.color,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Host",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: event.getOwner,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                return ShimmerLoading(
                                  isLoading: !snapshot.hasData,
                                  placeholder: placeholder(),
                                  builder: (BuildContext context) {
                                    User owner = snapshot.data;
                                    return GestureDetector(
                                      onTap: () => viewUserProfile(owner),
                                      child: Row(
                                        children: [
                                          avatar(url: owner.image),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${owner.name} ${owner.surname}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        Wrap(
                          runSpacing: 16,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.group_rounded,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      "Members",
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    ),
                                  ),
                                ),
                                Badge(
                                  title:
                                      "${event.member.length} / ${event.maxMember}",
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: FutureBuilder(
                                future: event.getMember,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  return ShimmerLoading(
                                    isLoading: !snapshot.hasData,
                                    placeholder: GridView.count(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      crossAxisCount: 8,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      children: [
                                        for (var i = 0; i < 4; i++) ...{
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Colors.black,
                                            ),
                                          ),
                                        }
                                      ],
                                    ),
                                    builder: (BuildContext context) {
                                      List<User> listMember = snapshot.data;

                                      if (listMember.isNotEmpty) {
                                        return GridView.count(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                          children: listMember.map((member) {
                                            if (user!.id == event.owner.id &&
                                                user.id != member.id) {
                                              // owner option to other user
                                              return showOwnerOtherUserMenu(
                                                  member);
                                            }

                                            // normal member / owner option to self
                                            return GestureDetector(
                                              onTap: () {
                                                viewUserProfile(member);
                                              },
                                              child: avatar(url: member.image),
                                            );
                                          }).toList(),
                                        );
                                      }

                                      return const SizedBox();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        //
                        if (canJoinEvent()) ...{
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    joinEvent();
                                  },
                                  child: const Text("JOIN"),
                                ),
                              ),
                            ],
                          ),
                        },
                        if (canReviewUser()) ...{
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: Theme.of(context)
                                      .elevatedButtonTheme
                                      .style!
                                      .copyWith(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return Theme.of(context)
                                              .disabledColor;
                                        }
                                        return Theme.of(context)
                                            .extension<LetsMeetColor>()!
                                            .rating;
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<GlobalKey<NavigatorState>>()
                                        .currentState!
                                        .pushNamed("/event/review",
                                            arguments: event);
                                  },
                                  child: const Text("REVIEW"),
                                ),
                              ),
                            ],
                          ),
                        }
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
