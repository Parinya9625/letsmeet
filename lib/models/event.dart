import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/search_index.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/user.dart';

class Event {
  final String? id;
  final bool ageRestrict;
  final DocumentReference category;
  final DateTime createdTime;
  final String description;
  final String image;
  final EventLocation location;
  final int maxMember;
  final List<DocumentReference> member;
  final List<DocumentReference> memberReviewed;
  final String name;
  final DocumentReference owner;
  final DateTime startTime;
  final String type;
  final List<String> searchIndex;

  Event({
    required this.id,
    required this.ageRestrict,
    required this.category,
    required this.createdTime,
    required this.description,
    required this.image,
    required this.location,
    required this.maxMember,
    required this.member,
    required this.memberReviewed,
    required this.name,
    required this.owner,
    required this.startTime,
    required this.type,
    required this.searchIndex,
  });
  Event.createInPerson(
      {required this.ageRestrict,
      required this.category,
      required this.description,
      required this.image,
      required String placeId,
      required String locationName,
      required GeoPoint geoPoint,
      required this.maxMember,
      required this.member,
      required this.name,
      required this.owner,
      required this.startTime})
      : id = null,
        createdTime = DateTime.now(),
        memberReviewed = [],
        location = EventLocation(
          placeId: placeId,
          name: locationName,
          geoPoint: geoPoint,
        ),
        type = "In Person",
        searchIndex = getSearchIndex(name);

  Event.createOnline(
      {required this.ageRestrict,
      required this.category,
      required this.description,
      required this.image,
      required String link,
      required this.maxMember,
      required this.member,
      required this.name,
      required this.owner,
      required this.startTime})
      : id = null,
        createdTime = DateTime.now(),
        memberReviewed = [],
        location = EventLocation(
          name: "Online event",
          link: link,
        ),
        type = "Online",
        searchIndex = getSearchIndex(name);

  Future<Category> get getCategory async =>
      Category.fromFirestore(doc: await category.get());

  Future<User> get getOwner async => User.fromFirestore(doc: await owner.get());

  Future<List<User>> get getMember => Future.wait(
      member.map((ref) async => User.fromFirestore(doc: await ref.get())));

  Future<List<User>> get getMemberReviewed => Future.wait(memberReviewed
      .map((ref) async => User.fromFirestore(doc: await ref.get())));

  factory Event.fromFirestore({required DocumentSnapshot doc}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      ageRestrict: data["ageRestrict"],
      category: data["category"],
      createdTime: data["createdTime"].toDate(),
      description: data["description"],
      image: data["image"],
      location: EventLocation.fromMap(map: data["location"]),
      maxMember: data["maxMember"],
      member: List<DocumentReference>.from(data["member"]),
      memberReviewed: List<DocumentReference>.from(data["memberReviewed"]),
      name: data["name"],
      owner: data["owner"],
      startTime: data["startTime"].toDate(),
      type: data["type"],
      searchIndex: List<String>.from(data["searchIndex"] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "ageRestrict": ageRestrict,
      "category": category,
      "createdTime": createdTime,
      "description": description,
      "image": image,
      "location": location.toMap(),
      "maxMember": maxMember,
      "member": member,
      "memberReviewed": memberReviewed,
      "name": name,
      "owner": owner,
      "startTime": startTime,
      "type": type,
      "searchIndex": searchIndex,
    };
  }

  DocumentReference toDocRef() {
    return FirebaseFirestore.instance.collection(CollectionPath.events).doc(id);
  }

  @override
  String toString() {
    return "$id - $member";
  }
}

class EventLocation {
  final String? placeId;
  final String name;
  final GeoPoint? geoPoint;
  final String? link;

  EventLocation({
    required this.name,
    this.placeId,
    this.geoPoint,
    this.link,
  });

  factory EventLocation.fromMap({required Map<String, dynamic> map}) {
    return EventLocation(
      name: map["name"],
      placeId: map["placeId"],
      geoPoint: map["geoPoint"],
      link: map["link"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "placeId": placeId,
      "name": name,
      "geoPoint": geoPoint,
      "link": link,
    };
  }
}
