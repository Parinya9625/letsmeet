import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/user.dart';

class ChatBubble extends StatefulWidget {
  final Chat chat;
  final bool isSender;
  final bool isContinue;
  final bool showTime;
  final VoidCallback? onTapProfile;

  const ChatBubble({
    Key? key,
    required this.chat,
    this.isSender = false,
    this.isContinue = false,
    this.showTime = true,
    this.onTapProfile,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Widget chatTime() {
    return Text(
      DateFormat("HH:mm").format(widget.chat.sendTime),
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  Widget viewImage(String imageUrl) {
    return Scaffold(
      appBar: AppBar(),
      body: InteractiveViewer(
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
    );
  }

  List<Widget> chatBubble(BoxConstraints constraints, User user) {
    return [
      // time
      if (!widget.isSender && widget.showTime) ...{
        chatTime(),
      },
      // profile and chat
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profile
          if (widget.isSender) ...{
            if (widget.isContinue) ...{
              const SizedBox(
                width: 40,
                height: 40,
              ),
            } else ...{
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onTap: widget.onTapProfile,
                  child: CachedNetworkImage(
                    imageUrl: user.image,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            },
          },
          // chat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth / 1.5),
              child: Card(
                color: widget.isSender
                    ? Theme.of(context).cardColor
                    : Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // sender name
                      if (widget.isSender && !widget.isContinue) ...{
                        Text(
                          "${user.name} ${user.surname}",
                          style:
                              Theme.of(context).textTheme.headline1!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        const SizedBox(height: 6),
                      },
                      // text chat
                      if (widget.chat.text != null) ...{
                        SelectableText(
                          widget.chat.text!,
                          style: widget.isSender
                              ? Theme.of(context).textTheme.headline1
                              : Theme.of(context).textTheme.headline1!.copyWith(
                                    color: Theme.of(context).cardColor,
                                  ),
                        ),
                      },
                      // image
                      if (widget.chat.image.isNotEmpty) ...{
                        if (widget.chat.text != null) ...{
                          const SizedBox(height: 6),
                        },
                        GridView.count(
                          primary: false,
                          shrinkWrap: true,
                          crossAxisCount: widget.chat.image.length > 3
                              ? 3
                              : widget.chat.image.length,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          children: [
                            for (String imageUrl in widget.chat.image) ...{
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            viewImage(imageUrl)),
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            }
                          ],
                        ),
                      },
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // time
      if (widget.isSender && widget.showTime) ...{
        chatTime(),
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Alert
        if (widget.chat.isAlert) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 1.25),
            child: Card(
              color: Theme.of(context).cardColor.withOpacity(0.75),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    if (widget.showTime) ...{
                      chatTime(),
                    },
                    const SizedBox(height: 4),
                    Text(
                      widget.chat.text.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Chat bubble
        return FutureBuilder(
          future: Future.wait([widget.chat.getBy]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading");
            }

            User user = snapshot.data[0];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: widget.isSender
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: chatBubble(constraints, user),
            );
          },
        );
      },
    );
  }
}
