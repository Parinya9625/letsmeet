import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';

class Role {
  final String? id;
  final String name;
  final Color foregroundColor;
  final Color backgroundColor;
  final UserPermission permission;

  Role(
      {required this.id,
      required this.name,
      required this.foregroundColor,
      required this.backgroundColor,
      required this.permission});
  Role.create(
      {required this.name,
      required this.foregroundColor,
      required this.backgroundColor,
      required this.permission})
      : id = null;

  factory Role.fromFirestore({required DocumentSnapshot doc}) {
    if (!doc.exists) {
      return Role(
        id: doc.id,
        name: "Unknown",
        foregroundColor: const Color.fromRGBO(254, 239, 0, 1),
        backgroundColor: const Color.fromRGBO(227, 85, 15, 1),
        permission: UserPermission(
          isAdmin: false,
        ),
      );
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Role(
      id: doc.id,
      name: data["name"],
      foregroundColor: Color.fromRGBO(
          data["foregroundColor"]["r"],
          data["foregroundColor"]["g"],
          data["foregroundColor"]["b"],
          (data["foregroundColor"]["o"] as int).toDouble()),
      backgroundColor: Color.fromRGBO(
        data["backgroundColor"]["r"],
        data["backgroundColor"]["g"],
        data["backgroundColor"]["b"],
        (data["backgroundColor"]["o"] as int).toDouble(),
      ),
      permission: UserPermission.fromMap(map: data["permission"]),
    );
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance.collection(CollectionPath.roles).doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "foregroundColor": {
        "r": foregroundColor.red,
        "g": foregroundColor.green,
        "b": foregroundColor.blue,
        "o": foregroundColor.opacity,
      },
      "backgroundColor": {
        "r": backgroundColor.red,
        "g": backgroundColor.green,
        "b": backgroundColor.blue,
        "o": backgroundColor.opacity,
      },
      "permission": permission.toMap(),
    };
  }
}

class UserPermission {
  final bool isAdmin;

  UserPermission({
    this.isAdmin = false,
  });

  factory UserPermission.fromMap({required Map<String, dynamic> map}) {
    return UserPermission(
      isAdmin: map["isAdmin"] ?? false,
    );
  }

  Map<String, bool> toMap() {
    return {
      "isAdmin": isAdmin,
    };
  }
}
