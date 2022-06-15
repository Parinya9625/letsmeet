import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';
import 'package:intl/intl.dart';

class SearchEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onPressed;

  const SearchEventCard({Key? key, required this.event, this.onPressed})
      : super(key: key);

  @override
  State<SearchEventCard> createState() => _SearchEventCardState();
}

class _SearchEventCardState extends State<SearchEventCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.event.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(widget.event.name,
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          FutureBuilder(
                            future: Future.wait([widget.event.getOwner]),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData) {
                                return const Text(
                                  "Loading",
                                  style: TextStyle(color: Colors.grey),
                                );
                              }
                              User user = snapshot.data[0];
                              return Text(
                                "${user.name} ${user.surname}",
                                style: const TextStyle(color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              widget.event.type == "Online"
                                  ? Icons.videocam_rounded
                                  : Icons.place_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.event.location["name"],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            DateFormat("EEE, dd MMM y, HH:mm")
                                .format(widget.event.startTime),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}