import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/user.dart';

class ChatGroupCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onPressed;

  const ChatGroupCard({Key? key, required this.event, this.onPressed})
      : super(key: key);

  @override
  State<ChatGroupCard> createState() => _ChatGroupCardState();
}

class _ChatGroupCardState extends State<ChatGroupCard> {
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
                  width: 70,
                  height: 70,
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
                      Text(
                        "last message • 32 mins",
                        style: Theme.of(context).textTheme.bodyText1,
                      )
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
