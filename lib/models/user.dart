import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/services/search_index.dart';

class UserRating {
  final int r1;
  final int r2;
  final int r3;
  final int r4;
  final int r5;

  UserRating({
    this.r1 = 0,
    this.r2 = 0,
    this.r3 = 0,
    this.r4 = 0,
    this.r5 = 0,
  });

  factory UserRating.fromMap(Map<String, int> value) {
    return UserRating(
      r1: value["1"]!,
      r2: value["2"]!,
      r3: value["3"]!,
      r4: value["4"]!,
      r5: value["5"]!,
    );
  }

  Map<String, int> toMap() {
    return {
      "1": r1,
      "2": r2,
      "3": r3,
      "4": r4,
      "5": r5,
    };
  }

  Map<String, int> reverseMap() {
    return {
      "5": r5,
      "4": r4,
      "3": r3,
      "2": r2,
      "1": r1,
    };
  }

  int amount() {
    return r1 + r2 + r3 + r4 + r5;
  }

  int total() {
    return r1 + (r2 * 2) + (r3 * 3) + (r4 * 4) + (r5 * 5);
  }

  double average() {
    if (amount() == 0) {
      return 0;
    }
    return total() / amount();
  }

  int min() {
    return [r1, r2, r3, r4, r5].reduce(math.min);
  }

  int max() {
    return [r1, r2, r3, r4, r5].reduce(math.max);
  }
}

class User {
  final String? id;
  final String bio;
  final DateTime birthday;
  final DateTime createdTime;
  final List<DocumentReference> favCategory;
  final String image;
  final String name;
  final UserRating rating;
  final List<DocumentReference> recentView;
  final DocumentReference role;
  final String surname;
  final bool isFinishSetup;
  final List<String> searchIndex;

  User({
    required this.id,
    required this.bio,
    required this.birthday,
    required this.createdTime,
    required this.favCategory,
    required this.image,
    required this.name,
    required this.rating,
    required this.recentView,
    required this.role,
    required this.surname,
    required this.isFinishSetup,
    required this.searchIndex,
  });
  User.create({
    required this.birthday,
    required this.image,
    required this.name,
    required this.surname,
    DateTime? createdTime,
  })  : id = null,
        bio = "",
        createdTime = createdTime ?? DateTime.now(),
        favCategory = [],
        rating = UserRating(),
        recentView = [],
        isFinishSetup = false,
        role = FirebaseFirestore.instance
            .collection(CollectionPath.roles)
            .doc("user"),
        searchIndex = getSearchIndex("$name $surname");
  User.createWithID({
    required this.id,
    required this.birthday,
    required this.image,
    required this.name,
    required this.surname,
    DateTime? createdTime,
  })  : bio = "",
        createdTime = createdTime ?? DateTime.now(),
        favCategory = [],
        rating = UserRating(),
        recentView = [],
        isFinishSetup = false,
        role = FirebaseFirestore.instance
            .collection(CollectionPath.roles)
            .doc("user"),
        searchIndex = getSearchIndex("$name $surname");

  Future<Role> get getRole async => Role.fromFirestore(doc: await role.get());

  Future<List<Category>> get getFavCategory => Future.wait(favCategory
      .map((ref) async => Category.fromFirestore(doc: await ref.get())));

  Future<List<Event?>> get getRecentView {
    var rv = recentView.map((ref) async {
      var doc = await ref.get();

      return doc.exists ? Event.fromFirestore(doc: doc) : null;
    });

    return Future.wait(rv);
  }

  Future<bool> get isBanned {
    return FirebaseFirestore.instance
        .collection(CollectionPath.bans)
        .doc(id)
        .get()
        .then((snapshot) => snapshot.exists);
  }

  factory User.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      bio: data["bio"],
      birthday: data["birthday"].toDate(),
      createdTime: data["createdTime"].toDate(),
      favCategory: List<DocumentReference>.from(data["favCategory"]),
      image: data["image"],
      name: data["name"],
      rating: UserRating.fromMap(Map<String, int>.from(data["rating"])),
      recentView: List<DocumentReference>.from(data["recentView"]),
      role: data["role"],
      surname: data["surname"],
      isFinishSetup: data["isFinishSetup"] ?? true,
      searchIndex: List<String>.from(data["searchIndex"] ?? []),
    );
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance.collection(CollectionPath.users).doc(id);
  }

  Map<String, dynamic> toMap() {
    return {
      "bio": bio,
      "birthday": birthday,
      "createdTime": createdTime,
      "favCategory": favCategory,
      "image": image,
      "name": name,
      "rating": rating.toMap(),
      "recentView": recentView,
      "role": role,
      "surname": surname,
      "isFinishSetup": isFinishSetup,
      "searchIndex": searchIndex,
    };
  }
}
