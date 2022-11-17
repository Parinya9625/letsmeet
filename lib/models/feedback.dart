import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/services/firestore.dart';

class Feedback {
  final String? id;
  final DateTime createdTime;
  final String message;
  final DocumentReference by;

  Feedback({
    required this.id,
    required this.createdTime,
    required this.message,
    required this.by,
  });

  Feedback.create({
    required this.message,
    required this.by,
    DateTime? createdTime,
  })  : id = null,
        createdTime = createdTime ?? DateTime.now();

  Future<User> get getBy async => User.fromFirestore(doc: await by.get());

  factory Feedback.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Feedback(
      id: doc.id,
      createdTime: data["createdTime"].toDate(),
      message: data["message"],
      by: data["by"],
    );
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPath.feedbacks)
        .doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "createdTime": createdTime,
      "message": message,
      "by": by,
    };
  }
}
