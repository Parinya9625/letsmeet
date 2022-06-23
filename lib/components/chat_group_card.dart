import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/event.dart';

class ChatGroupCard extends StatefulWidget {
  final Event event;
  final Chat? lastChat;
  final VoidCallback? onPressed;

  const ChatGroupCard(
      {Key? key, required this.event, this.lastChat, this.onPressed})
      : super(key: key);

  @override
  State<ChatGroupCard> createState() => _ChatGroupCardState();
}

class _ChatGroupCardState extends State<ChatGroupCard> {
  String timeDiff(DateTime sendTime) {
    Duration diff = DateTime.now().difference(sendTime);

    if ((diff.inDays ~/ 7) > 0) {
      return "${(diff.inDays ~/ 7)} week${(diff.inDays ~/ 7) > 1 ? 's' : ''}";
    } else if (diff.inDays > 0) {
      return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''}";
    } else if (diff.inHours > 0) {
      return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''}";
    }

    return "${diff.inSeconds} sec${diff.inSeconds > 1 ? 's' : ''}";
  }

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
                  width: 60,
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
                        widget.event.name,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      if (widget.lastChat != null) ...{
                        const SizedBox(height: 6),
                        Text(
                          "${widget.lastChat!.text}  •  ${timeDiff(widget.lastChat!.sendTime)}",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      }
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
