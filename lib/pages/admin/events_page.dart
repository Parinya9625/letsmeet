import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/admin/detail_dialog.dart';
import 'package:letsmeet/components/admin/responsive_layout.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> listEvent = [];
  List<User> listUser = [];
  List<Category> listCategory = [];
  List<Report> listReport = [];
  TextEditingController searchController = TextEditingController();
  List<String> filterOptions = [
    "All Events",
    "Reported Events",
  ];
  String selectedFilterOption = "All Events";
  FocusNode filterFocusNode = FocusNode();

  User? getUser(String id) {
    return listUser.firstWhereOrNull(
      (user) => user.id == id,
    );
  }

  Category? getCategory(String id) {
    return listCategory.firstWhereOrNull(
      (category) => category.id == id,
    );
  }

  Report? getReport(String id) {
    return listReport.firstWhereOrNull(
      (report) => report.id == id && report.type == "event",
    );
  }

  void confirmIgnoreReport(BuildContext detailContext, Event event) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm ignore report"),
            content: const Text(
                'Are you sure you want to ignore this event reported?\nAll reported detail will be remove after confirm this dialog.'),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  }),
              TextButton(
                  child: const Text("Confirm"),
                  onPressed: () {
                    context.read<CloudFirestoreService>().removeReport(
                          id: event.id!,
                        );

                    Navigator.pop(dialogContext);
                    Navigator.pop(detailContext);
                  }),
            ],
          );
        });
  }

  void confirmCloseEvent(BuildContext detailContext, Event event) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm close event"),
            content: Text('Are you sure you want to close "${event.name}"?'),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  }),
              TextButton(
                  child: const Text("Confirm"),
                  onPressed: () {
                    context.read<CloudFirestoreService>().removeReport(
                          id: event.id!,
                        );

                    context.read<CloudFirestoreService>().removeEvent(
                          id: event.id!,
                        );

                    Navigator.pop(dialogContext);
                    Navigator.pop(detailContext);
                  }),
            ],
          );
        });
  }

  Widget textDetail({String? title, String? text, List<Widget>? children}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headline2,
              children: [
                if (title != null) ...{
                  TextSpan(
                    text: title,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const TextSpan(text: "  "),
                },
                if (text != null) ...{
                  TextSpan(
                    text: text,
                  ),
                },
              ],
            ),
          ),
          ...?children,
        ],
      ),
    );
  }

  Widget leftPanelDialog(Event event) {
    Category? category = getCategory(event.category.id);
    User? owner = getUser(event.owner.id);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event Info",
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: event.image,
                      fit: BoxFit.cover,
                      width: 16 * 15,
                      height: 9 * 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          textDetail(
            title: "Name",
            text: event.name,
          ),
          textDetail(
            title: "Created Time",
            text: DateFormat("EEE, dd MMM y").format(event.createdTime),
          ),
          textDetail(
            title: "Type",
            text: event.type,
          ),
          textDetail(
            title: "Category",
            children: [
              if (category != null) ...{
                Icon(category.icon),
                const SizedBox(width: 8),
                Text(category.name),
              },
            ],
          ),
          textDetail(
            title: "Start Time",
            text: DateFormat("EEE, dd MMM y").format(event.startTime),
          ),
          textDetail(
            title: "Event Detail",
            text: event.description,
          ),
          textDetail(
            title: "Age Restrict",
            text: event.ageRestrict.toString(),
          ),
          textDetail(
            title: "Owner",
            children: [
              if (owner != null) ...{
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: owner.image,
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 8),
                Text("${owner.name} ${owner.surname}"),
              },
            ],
          ),
          textDetail(
            title: "Member",
            text: event.member.length.toString(),
          ),
          textDetail(
            title: "Max Member",
            text: event.maxMember.toString(),
          ),
        ],
      ),
    );
  }

  Widget reportSection(Event event) {
    Report? report = getReport(event.id!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Reported Detail",
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            if (report != null) ...{
              const SizedBox(width: 8),
              Text(
                "(${report.reason.length})",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            },
          ],
        ),
        const SizedBox(height: 16),
        if (report == null) ...{
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: FaIcon(
                      FontAwesomeIcons.solidFaceLaugh,
                      size: 96,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No report found for this event",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        } else ...{
          for (MapEntry<String, int> reason
              in report.reasonToMap().entries) ...{
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    reason.key,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: reason.value / report.reasonToMap().values.max,
                      minHeight: 12,
                      color: Theme.of(context).errorColor,
                      backgroundColor: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          },
        },
      ],
    );
  }

  Widget rightPanelDialog(Event event) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event Location",
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 16),
          if (event.type == "In Person") ...{
            textDetail(
              title: "Place ID",
              text: event.location.placeId,
            ),
            textDetail(
              title: "Name",
              text: event.location.name,
            ),
            textDetail(
              title: "Latitude",
              text: "${event.location.geoPoint?.latitude}",
            ),
            textDetail(
              title: "Longitude",
              text: "${event.location.geoPoint?.longitude}",
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.map_rounded),
                      SizedBox(width: 16),
                      Text("Open in Google Maps"),
                    ],
                  ),
                ),
                onPressed: () async {
                  String url =
                      "https://maps.google.com/?q=${event.location.geoPoint?.latitude},${event.location.geoPoint?.longitude}";

                  if (!await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                      webOnlyWindowName: "_blank")) {}
                  // if launch url fail
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Could not launch ${url}",
                      ),
                    ),
                  );
                },
              ),
            ),
          } else ...{
            textDetail(
              title: "Name",
              text: event.location.name,
            ),
            textDetail(
              title: "Link",
              text: event.location.link,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.language_rounded),
                      SizedBox(width: 16),
                      Text("Open Link"),
                    ],
                  ),
                ),
                onPressed: () async {
                  if (!await launchUrl(Uri.parse(event.location.link!),
                      mode: LaunchMode.externalApplication,
                      webOnlyWindowName: "_blank")) {}
                  // if launch url fail
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Could not launch ${event.location.link}",
                      ),
                    ),
                  );
                },
              ),
            ),
          },
          const SizedBox(height: 16),
          reportSection(event),
        ],
      ),
    );
  }

  void eventDialog({required Event event}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Report? report = getReport(event.id!);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DetailDialog(
              width: 512 + 256 + 128,
              menus: [
                if (report != null) ...{
                  DetailDialogMenuButton(
                    child: Row(
                      children: const [
                        Icon(Icons.report_off_rounded),
                        SizedBox(width: 16),
                        Text("Ignore Report"),
                      ],
                    ),
                    onPressed: () {
                      confirmIgnoreReport(context, event);
                    },
                  ),
                },
                DetailDialogMenuButton(
                  child: Row(
                    children: const [
                      Icon(Icons.block_rounded),
                      SizedBox(width: 16),
                      Text("Close Event"),
                    ],
                  ),
                  onPressed: () {
                    confirmCloseEvent(context, event);
                  },
                ),
                DetailDialogMenuButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leftPanelDialog(event),
                  rightPanelDialog(event),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget eventCard(Event event) {
    User? owner = getUser(event.owner.id);

    return GestureDetector(
      onTap: () {
        eventDialog(
          event: event,
        );
      },
      child: Card(
        margin: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: event.image,
                    fit: BoxFit.cover,
                    width: 16 * 10,
                    height: 9 * 10,
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 8,
                  children: [
                    Row(
                      children: [
                        Text(
                          event.name,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded),
                        const SizedBox(width: 8),
                        Text(
                          "Location : ${event.location.name}",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded),
                        const SizedBox(width: 8),
                        Text(
                          "Owner : ${owner != null ? '${owner.name} ${owner.surname}' : '!! UNKNOWN !!'}",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "Events",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: DropdownButton(
              borderRadius: BorderRadius.circular(16),
              underline: const SizedBox(),
              icon: const Padding(
                padding: EdgeInsets.only(
                  right: 4,
                ),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 32,
                ),
              ),
              isExpanded: true,
              focusNode: filterFocusNode,
              value: selectedFilterOption,
              items: filterOptions
                  .map(
                    (filter) => DropdownMenuItem(
                      value: filter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Text(filter),
                      ),
                    ),
                  )
                  .toList(),
              onTap: () {
                filterFocusNode.unfocus();
              },
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedFilterOption = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 2,
          child: InputField(
            controller: searchController,
            icon: const Icon(Icons.search_rounded),
            hintText: "Search by event name",
            onClear: () {
              setState(() {});
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    listUser = context.watch<List<User>?>() ?? [];
    listCategory = context.watch<List<Category>?>() ?? [];
    listReport = context.watch<List<Report>?>() ?? [];
    listEvent = context.watch<List<Event>?>() ?? [];

    // sort event
    if (listEvent != [] && listEvent.length >= 2) {
      listEvent.sort(
          (eventA, eventB) => eventB.createdTime.compareTo(eventA.createdTime));
    }
    // search text
    if (searchController.text.trim().isNotEmpty) {
      listEvent = listEvent.where((event) {
        List<String> words =
            searchController.text.toLowerCase().trim().split(" ");
        User? user = getUser(event.owner.id);
        String fullname = user != null ? "${user.name} ${user.surname}" : "";

        return words.every((word) =>
            event.name.toLowerCase().contains(word) ||
            event.location.name.toLowerCase().contains(word) ||
            fullname.toLowerCase().contains(word));
      }).toList();
    }
    // filter by options
    if (selectedFilterOption == "Reported Events") {
      listEvent =
          listEvent.where((event) => getReport(event.id!) != null).toList();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              topSection(),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: ResponsiveValue(
                  context: context,
                  small: 1,
                  medium: 1,
                  large: 3,
                ),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 4 / 1,
                children: [
                  for (Event event in listEvent) ...{
                    eventCard(event),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}