import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/services/firestore.dart';

class Category {
  final String? id;
  final String name;
  final IconData icon;

  Category({required this.id, required this.name, required this.icon});
  Category.create({required this.name, required this.icon}) : id = null;

  factory Category.fromFirestore({required DocumentSnapshot doc}) {
    if (!doc.exists) {
      return Category(
        id: doc.id,
        name: "Unknown",
        icon: Icons.question_mark,
      );
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Category(
      id: doc.id,
      name: data["name"],
      icon: IconData(
        data["icon"]["codePoint"],
        fontFamily: data["icon"]["fontFamily"],
        fontPackage: data["icon"]["fontPackage"],
      ),
    );
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPath.categories)
        .doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "icon": {
        "codePoint": icon.codePoint,
        "fontFamily": icon.fontFamily,
        "fontPackage": icon.fontPackage,
      },
    };
  }
}
