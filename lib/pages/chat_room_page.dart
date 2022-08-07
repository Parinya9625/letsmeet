// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/storage.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/chat_bubble.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/user.dart';

class ChatRoomPage extends StatefulWidget {
  final Event event;

  const ChatRoomPage({Key? key, required this.event}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController textController = TextEditingController();
  FocusNode textFocusNode = FocusNode();
  bool canSend = false;
  Map<String, User?> listUserCache = {};
  ScrollController scrollController = ScrollController();
  List<XFile> selectedImages = [];
  Map<String, Chat> waitingChats = {};
  late StateSetter chatSetState;

  Widget pickerOptionButton(
      {VoidCallback? onPressed, required IconData icon, String? text}) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                text.toString(),
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openCamera() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 128, imageQuality: 50);

    if (file != null) {
      selectedImages.add(file);
      updateSendButton();
    }

    setState(() {
      Navigator.pop(context);
    });
  }

  void openGallery() async {
    ImagePicker picker = ImagePicker();
    List<XFile>? listFile =
        await picker.pickMultiImage(maxHeight: 128, imageQuality: 50);

    if (listFile != null) {
      selectedImages.addAll(listFile);
      updateSendButton();
    }

    setState(() {
      Navigator.pop(context);
    });
  }

  void showPickerOption() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select image with",
                  style: Theme.of(context).textTheme.headline1,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    pickerOptionButton(
                      onPressed: openCamera,
                      icon: Icons.photo_camera_rounded,
                      text: "Camera",
                    ),
                    pickerOptionButton(
                      onPressed: openGallery,
                      icon: Icons.photo_library_rounded,
                      text: "Gallery",
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void viewUserProfile(User member) {
    context.read<GlobalKey<NavigatorState>>().currentState!.pushNamed(
      "/profile",
      arguments: {
        "userId": member.id,
        "isOtherUser": true,
      },
    );
  }

  Widget chatView(User? user) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(widget.event.id)
            .collection("chats")
            .orderBy(
              "sendTime",
              descending: true,
            )
            .limit(100)
            .snapshots()
            .map((chats) => chats.docs
                .map((doc) => Chat.fromFirestore(
                      doc: doc,
                    ))
                .toList()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Loading chat
          List<Chat> listChat = snapshot.data;

          // Find user that not in cache data
          List<Future<User>> newUser = listChat
              .where((chat) =>
                  chat.by != null && !listUserCache.keys.contains(chat.by?.id))
              .map((chat) {
            listUserCache[chat.by!.id] = null;
            return chat.getBy;
          }).toList();

          // Save new user data to cache for better load time
          return FutureBuilder(
              future: Future.wait(newUser),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<User> listUser = snapshot.data;
                  for (var userData in listUser) {
                    listUserCache[userData.id!] = userData;
                  }
                }

                // Display chat
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter chatState) {
                  chatSetState = chatState;

                  int lastIndex = listChat.length - 1;
                  int waitingChatLength = waitingChats.values.toList().length;

                  return Scrollbar(
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        controller: scrollController,
                        reverse: true,
                        itemCount: listChat.length + waitingChatLength,
                        itemBuilder: (BuildContext context, int index) {
                          // Waiting chat builder
                          if (index < waitingChatLength) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              child: ProgressChatBubble(
                                chat: waitingChats.values.toList()[index],
                              ),
                            );
                          }

                          // All chat in firestore
                          int realIndex = index - waitingChatLength;

                          User? chatBy =
                              listUserCache[listChat[realIndex].by?.id];
                          bool isNextDay = realIndex == lastIndex ||
                              DateFormat.yMd().format(
                                      listChat[realIndex + 1].sendTime) !=
                                  DateFormat.yMd()
                                      .format(listChat[realIndex].sendTime);
                          bool isContinue = realIndex != lastIndex &&
                              listChat[realIndex].by != null &&
                              listChat[realIndex + 1].by!.id ==
                                  listChat[realIndex].by!.id;

                          Random random = Random();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Wrap(
                              runSpacing: 8,
                              children: [
                                if (isNextDay) ...{
                                  ChatBubble(
                                    by: null,
                                    showTime: false,
                                    chat: Chat.createAlert(
                                        text: DateFormat("dd MMMM y").format(
                                            listChat[realIndex].sendTime)),
                                  ),
                                },
                                ChatBubble(
                                  by: chatBy,
                                  chat: listChat[realIndex],
                                  isSender: chatBy != null
                                      ? user!.id != chatBy.id
                                      : random.nextBool(),
                                  isContinue: chatBy != null
                                      ? isContinue && !isNextDay
                                      : false,
                                  onTapProfile: () {
                                    // view user profile (not owner)
                                    if (chatBy != null) {
                                      viewUserProfile(chatBy);
                                    }
                                  },
                                  customProfileAvatar:
                                      user?.id == widget.event.owner.id &&
                                              chatBy != null &&
                                              widget.event.member
                                                  .contains(chatBy.toDocRef())
                                          ? showOwnerMenu(chatBy)
                                          : null,
                                ),
                              ],
                            ),
                          );
                        }),
                  );
                });
              });
        });
  }

  void updateSendButton() {
    if (textController.text.trim().isEmpty && selectedImages.isEmpty) {
      setState(() {
        canSend = false;
      });
    } else if (!canSend) {
      setState(() {
        canSend = true;
      });
    }
  }

  Widget messageSection(User? user) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: selectedImages.isEmpty ? 4 : 0,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
                icon: const Icon(Icons.image_rounded),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  showPickerOption();
                }),
          ),
          Expanded(
            child: InputField(
              controller: textController,
              focusNode: textFocusNode,
              elevation: 0,
              backgroundColor: Colors.black.withOpacity(0.025),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              minLines: 1,
              maxLines: 5,
              hintText: "Type a message",
              onChanged: (value) {
                updateSendButton();
              },
              onClear: () {
                updateSendButton();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.send_rounded),
              color: Theme.of(context).primaryColor,
              onPressed: canSend
                  ? () async {
                      if (selectedImages.isEmpty) {
                        // Only text message
                        Chat chat = Chat.create(
                          by: user!.toDocRef(),
                          text: textController.text,
                        );

                        context.read<CloudFirestoreService>().addChat(
                              eventId: widget.event.id!,
                              chat: chat,
                            );
                      } else {
                        // Both Text and image
                        // Generate chat key
                        String key =
                            DateTime.now().millisecondsSinceEpoch.toString();

                        // Add chat to waiting list
                        setState(() {
                          waitingChats[key] = Chat.create(
                            by: user!.toDocRef(),
                            text: textController.text.trim().isNotEmpty
                                ? textController.text
                                : null,
                          );
                        });

                        // upload every image
                        Future.wait(selectedImages
                                .map(
                                  (xfile) => context
                                      .read<StorageService>()
                                      .uploadImage(
                                        userId: user!.id!,
                                        file: File(xfile.path),
                                      ),
                                )
                                .toList())
                            .then((listImage) {
                          // after upload complete
                          setState(() {
                            Chat currentChat = waitingChats[key]!;

                            // add chat to firestore
                            context.read<CloudFirestoreService>().addChat(
                                  eventId: widget.event.id!,
                                  chat: Chat(
                                    id: null,
                                    sendTime: currentChat.sendTime,
                                    by: currentChat.by,
                                    text: currentChat.text,
                                    image: listImage,
                                    isAlert: currentChat.isAlert,
                                  ),
                                );

                            // remove this chat from waiting list
                            waitingChats.remove(key);
                          });
                        });
                      }

                      // Clear everything
                      textController.clear();
                      selectedImages.clear();
                      textFocusNode.unfocus();
                      updateSendButton();

                      // SetState chat view
                      chatSetState(() {});

                      scrollController.jumpTo(0);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget miniImage(XFile file) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(file.path),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).errorColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 8,
                icon: const Icon(Icons.close_rounded, size: 16),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    selectedImages.remove(file);
                    updateSendButton();
                  });
                }),
          ),
        ),
      ],
    );
  }

  Widget imageSection() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  children: [
                    for (XFile file in selectedImages) ...{
                      miniImage(file),
                    }
                  ],
                ),
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

  Widget showOwnerMenu(User member) {
    GlobalKey<PopupMenuButtonState<String>> popupMenuKey = GlobalKey();
    return PopupMenuButton(
      key: popupMenuKey,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        popupMenuItem(icons: Icons.person_rounded, title: "View profile"),
        popupMenuItem(icons: Icons.person_remove_rounded, title: "Kick member"),
      ],
      onSelected: (selected) {
        switch (selected) {
          case "View profile":
            viewUserProfile(member);
            break;
          case "Kick member":
            confirmKickMember(member);
            break;
        }
      },
      child: GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: member.image,
              width: 40,
              height: 40,
            ),
          ),
          onTap: () {
            popupMenuKey.currentState!.showButtonMenu();
          }),
    );
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
        });
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
                  }),
              TextButton(
                  child: const Text("Kick"),
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    showLoading();
                    await context
                        .read<CloudFirestoreService>()
                        .removeEventMember(
                          event: widget.event,
                          user: member,
                        );

                    Navigator.pop(context);

                    setState(() {
                      widget.event.member.remove(member.toDocRef());
                    });
                  }),
            ],
          );
        });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.read<User?>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        actions: [
          PopupMenuButton(
            position: PopupMenuPosition.under,
            itemBuilder: (context) {
              return [
                popupMenuItem(
                  icons: Icons.event_rounded,
                  title: "View event",
                ),
              ];
            },
            onSelected: (selected) {
              switch (selected) {
                case "View event":
                  context
                      .read<GlobalKey<NavigatorState>>()
                      .currentState!
                      .pushNamed(
                        "/event",
                        arguments: widget.event,
                      );
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                textFocusNode.unfocus();
              },
              child: chatView(user),
            ),
          ),
          if (selectedImages.isNotEmpty) ...{
            imageSection(),
          },
          messageSection(user),
        ],
      ),
    );
  }
}
