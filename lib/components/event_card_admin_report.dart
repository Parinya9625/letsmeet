import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';

class AdminEventCardReport extends StatefulWidget {
  final Event event;
  final VoidCallback? onPressed;

  const AdminEventCardReport({Key? key, required this.event, this.onPressed})
      : super(key: key);

  @override
  State<AdminEventCardReport> createState() => _AdminEventCardReportState();
}

class _AdminEventCardReportState extends State<AdminEventCardReport> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.event.image,
                  fit: BoxFit.cover,
                  width: 130,
                  height: 60,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.event.name}",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 5,
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
                                style: Theme.of(context).textTheme.bodyText1,
                              );
                            },
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Wrap(
                            children: [
                              Icon(
                                Icons.warning,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Reported Count : 3",
                                style: Theme.of(context).textTheme.bodyText1,
                              )
                            ],
                          )
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
