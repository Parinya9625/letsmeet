import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/badge.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/style.dart';
import 'package:provider/provider.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final bool isReviewed;
  final bool isSmall;
  final VoidCallback? onPressed;

  const EventCard({
    Key? key,
    required this.event,
    this.isReviewed = false,
    this.isSmall = false,
    this.onPressed,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

enum PopupMenuValue {
  report,
}

class _EventCardState extends State<EventCard> {
  List<String> reportOption = [
    "Fake event",
    "Harassment",
    "Nudity",
    "Spam",
    "Suicide or self-injury",
    "Violence"
  ]..sort();

  Future<void> showReportDialog() {
    int? selectedReport;
    return showDialog(
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
                                  id: widget.event.id!,
                                  reason: [reportOption[selectedReport!]],
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

  Widget popupMenu() {
    GlobalKey<PopupMenuButtonState<PopupMenuValue>> key = GlobalKey();

    return PopupMenuButton(
      key: key,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: PopupMenuValue.report,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.flag_rounded,
              color: Theme.of(context).textTheme.headline1!.color,
            ),
            title: Text(
              "Report",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
        ),
      ],
      onSelected: (selected) {
        switch (selected) {
          case PopupMenuValue.report:
            {
              showReportDialog();
            }
            break;
        }
      },
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightForFinite(),
        icon: const Icon(Icons.more_vert_rounded),
        color: Colors.white,
        onPressed: () {
          key.currentState!.showButtonMenu();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isSmall ? 160 : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.event.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.event.ageRestrict) ...{
                        Badge(
                          title: "Over 20+",
                          backgroundColor: Theme.of(context)
                              .extension<LetsMeetColor>()!
                              .eventRestrict,
                        ),
                      },
                      if (!widget.isSmall) ...{
                        if (!widget.event.startTime
                                .difference(DateTime.now())
                                .isNegative &&
                            widget.event.member.length <
                                widget.event.maxMember) ...{
                          Badge(
                            title: "Open",
                            backgroundColor: Theme.of(context)
                                .extension<LetsMeetColor>()!
                                .eventOpen,
                          ),
                        } else ...{
                          if (!widget.isReviewed) ...{
                            Badge(
                              title: "Wait for review",
                              backgroundColor: Theme.of(context)
                                  .extension<LetsMeetColor>()!
                                  .rating,
                            ),
                          } else ...{
                            Badge(
                              title: "Ended",
                              backgroundColor: Theme.of(context)
                                  .extension<LetsMeetColor>()!
                                  .eventClose,
                            ),
                          },
                        },
                      },
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // ClipRRect on backdrop for limit blur effect
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.event.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                                popupMenu(),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    widget.event.type == "Online"
                                        ? Icons.videocam_rounded
                                        : Icons.place_rounded,
                                    size: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.event.location.name,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    DateFormat("EEE, dd MMM y, HH:mm")
                                        .format(widget.event.startTime),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
