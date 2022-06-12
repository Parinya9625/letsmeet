import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';

class Ban {
  final String id;
  final DateTime banTime;
  final String reason;

  Ban({required this.id, required this.banTime, required this.reason});
  Ban.now({required this.id, required this.reason}) : banTime = DateTime.now();

  factory Ban.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Ban(
      id: doc.id,
      banTime: data["banTime"].toDate(),
      reason: data["reason"],
    );
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance.collection(CollectionPath.bans).doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "banTime": banTime,
      "reason": reason,
    };
  }
}
