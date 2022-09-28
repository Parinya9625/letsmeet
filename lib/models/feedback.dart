import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';

class Feedback {
  final String? id;
  final DateTime createdTime;
  final String message;

  Feedback({
    required this.id,
    required this.createdTime,
    required this.message,
  });

  Feedback.create({
    required this.message,
    DateTime? createdTime,
  })  : id = null,
        createdTime = createdTime ?? DateTime.now();

  factory Feedback.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Feedback(
      id: doc.id,
      createdTime: data["createdTime"].toDate(),
      message: data["message"],
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
    };
  }
}
