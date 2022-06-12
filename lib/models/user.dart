import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/role.dart';

class User {
  final String? id;
  final String bio;
  final DateTime birthday;
  final DateTime createdTime;
  final List<DocumentReference> favCategory;
  final String image;
  final String name;
  final List<double> rating;
  final List<DocumentReference> recentView;
  final DocumentReference role;
  final String surname;

  User(
      {required this.id,
      required this.bio,
      required this.birthday,
      required this.createdTime,
      required this.favCategory,
      required this.image,
      required this.name,
      required this.rating,
      required this.recentView,
      required this.role,
      required this.surname});
  User.create(
      {required this.bio,
      required this.birthday,
      required this.image,
      required this.name,
      required this.surname})
      : id = null,
        createdTime = DateTime.now(),
        favCategory = [],
        rating = [],
        recentView = [],
        role = FirebaseFirestore.instance
            .collection(CollectionPath.roles)
            .doc("user");
  User.createWithID(
      {required this.id,
      required this.bio,
      required this.birthday,
      required this.image,
      required this.name,
      required this.surname})
      : createdTime = DateTime.now(),
        favCategory = [],
        rating = [],
        recentView = [],
        role = FirebaseFirestore.instance
            .collection(CollectionPath.roles)
            .doc("user");

  Future<Role> get getRole async => Role.fromFirestore(doc: await role.get());

  Future<List<Category>> get getFavCategory => Future.wait(favCategory
      .map((ref) async => Category.fromFirestore(doc: await ref.get())));

  Future<List<Event>> get getRecentView => Future.wait(
      recentView.map((ref) async => Event.fromFirestore(doc: await ref.get())));

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
      rating: List<double>.from(data["rating"]),
      recentView: List<DocumentReference>.from(data["recentView"]),
      role: data["role"],
      surname: data["surname"],
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
      "rating": rating,
      "recentView": recentView,
      "role": role,
      "surname": surname,
    };
  }
}
