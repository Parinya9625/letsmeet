import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/components/shimmer.dart';
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
  Widget placeholder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: constraints.maxWidth,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: constraints.maxWidth,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: constraints.maxWidth / 2,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget searchEventData({required User owner}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text(
                        widget.event.name,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    Text(
                      "${owner.name} ${owner.surname}",
                      style: Theme.of(context).textTheme.bodyText1,
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
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    Text(
                      widget.event.location.name,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    Text(
                      DateFormat("EEE, dd MMM y, HH:mm")
                          .format(widget.event.startTime),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: Future.wait([widget.event.getOwner]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return ShimmerLoading(
                isLoading: !snapshot.hasData,
                placeholder: placeholder(),
                builder: (BuildContext context) {
                  User owner = snapshot.data[0];
                  return searchEventData(owner: owner);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
