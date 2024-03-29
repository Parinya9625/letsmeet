import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';

class Report {
  final String id;
  final int count;
  final List<String> reason;
  final String type;

  Report({
    required this.id,
    required this.count,
    required this.reason,
    required this.type,
  });
  Report.user({required this.id, required String reason})
      : count = 1,
        reason = [reason],
        type = "user";
  Report.event({required this.id, required String reason})
      : count = 1,
        reason = [reason],
        type = "event";

  factory Report.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Report(
      id: doc.id,
      count: data["count"],
      reason: List<String>.from(data["reason"]),
      type: data["type"],
    );
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPath.reports)
        .doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "count": count,
      "reason": reason,
      "type": type,
    };
  }

  Map<String, int> reasonToMap() {
    Map<String, int> map = {};

    for (var r in reason) {
      map[r] = map.containsKey(r) ? map[r]! + 1 : 1;
    }

    return SplayTreeMap.from(map, (k1, k2) => map[k2]! > map[k1]! ? 1 : -1);
  }
}
