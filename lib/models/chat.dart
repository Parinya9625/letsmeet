import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/models/user.dart';

class Chat {
  final String? id;
  final DocumentReference? by;
  final DateTime sendTime;
  final String? text;
  final List<String> image;
  final bool isAlert;

  Chat({
    required this.id,
    required this.by,
    required this.sendTime,
    required this.text,
    required this.image,
    required this.isAlert,
  });

  Chat.create({
    required this.by,
    required this.text,
    this.image = const [],
  })  : id = null,
        sendTime = DateTime.now(),
        isAlert = false;

  Chat.createAlert({
    required this.text,
  })  : id = null,
        sendTime = DateTime.now(),
        by = null,
        image = [],
        isAlert = true;

  Future<User> get getBy async => User.fromFirestore(doc: await by!.get());

  factory Chat.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Chat(
      id: doc.id,
      by: data["by"],
      sendTime: data["sendTime"].toDate(),
      text: data["text"],
      image: List<String>.from(data["image"]),
      isAlert: data["isAlert"] ?? false,
    );
  }

  DocumentReference toDocRef({required String eventId}) {
    return FirebaseFirestore.instance
        .collection(CollectionPath.events)
        .doc(eventId)
        .collection(SubcollectionPath.chats)
        .doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "by": by,
      "sendTime": sendTime,
      "text": text,
      "image": image,
      "isAlert": isAlert,
    };
  }
}
