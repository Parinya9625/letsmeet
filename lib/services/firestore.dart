import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/user.dart';

import '../models/ban.dart';
import '../models/chat.dart';
import '../models/report.dart';

class CollectionPath {
  CollectionPath._();

  static const String users = "users";
  static const String events = "events";
  static const String reports = "reports";
  static const String bans = "bans";
  static const String categories = "categories";
  static const String roles = "roles";
}

class SubcollectionPath {
  SubcollectionPath._();

  static const String chats = "chats";
}

class CloudFirestoreService {
  final FirebaseFirestore _firestore;

  CloudFirestoreService(this._firestore);

  // TEST ONLY
  Stream<List<Ban>> get streamBans =>
      _firestore.collection(CollectionPath.bans).snapshots().map((bans) =>
          bans.docs.map((doc) => Ban.fromFirestore(doc: doc)).toList());

  Stream<List<Report>> get streamReports =>
      _firestore.collection(CollectionPath.reports).snapshots().map((reports) =>
          reports.docs.map((doc) => Report.fromFirestore(doc: doc)).toList());

  Stream<List<User>> get streamUsers =>
      _firestore.collection(CollectionPath.users).snapshots().map((users) =>
          users.docs.map((doc) => User.fromFirestore(doc: doc)).toList());

  Stream<List<Event>> get streamEvents =>
      _firestore.collection(CollectionPath.events).snapshots().map((events) =>
          events.docs.map((doc) => Event.fromFirestore(doc: doc)).toList());

  Stream<List<Category>> get streamCategories => _firestore
      .collection(CollectionPath.categories)
      .orderBy("name")
      .snapshots()
      .map((categories) => categories.docs
          .map((doc) => Category.fromFirestore(doc: doc))
          .toList());

  Stream<List<Role>> get streamRoles =>
      _firestore.collection(CollectionPath.roles).snapshots().map((roles) =>
          roles.docs.map((doc) => Role.fromFirestore(doc: doc)).toList());

  // * ----------  BAN ----------

  addBan({required Ban ban}) {
    _firestore.runTransaction((transaction) async {
      transaction.set(ban.toDocRef(), ban.toMap());
    });
  }

  updateBan({required Ban ban}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(ban.toDocRef(), ban.toMap());
    });
  }

  removeBan({required String id}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference =
          _firestore.collection(CollectionPath.bans).doc(id);

      transaction.delete(documentReference);
    });
  }

  // * ----------  REPORT ----------

  addReport({required Report report}) {
    _firestore.runTransaction((transaction) async {
      var doc = await report.toDocRef().get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<String> reason = List<String>.from(data["reason"]);
        reason.addAll(report.reason);

        transaction.update(
          report.toDocRef(),
          {
            "count": data["count"] + 1,
            "reason": reason,
          },
        );
      } else {
        transaction.set(report.toDocRef(), report.toMap());
      }
    });
  }

  removeReport({required String id}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference =
          _firestore.collection(CollectionPath.reports).doc(id);

      transaction.delete(documentReference);
    });
  }

  // * ----------  USER ----------

  addUser({required User user}) {
    _firestore.runTransaction((transaction) async {
      transaction.set(user.toDocRef(), user.toMap());
    });
  }

  updateUser({required User user}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(user.toDocRef(), user.toMap());
    });
  }

  updateUserPartial({required String id, required Map<String, dynamic> data}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(_firestore.collection("users").doc(id), data);
    });
  }

  removeUser({required String id}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference =
          _firestore.collection(CollectionPath.users).doc(id);

      transaction.delete(documentReference);
    });
  }

  addUserRecentView({required User user, required Event event}) {
    _firestore.runTransaction((transaction) async {
      var doc = await user.toDocRef().get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<DocumentReference> recentView =
          List<DocumentReference>.from(data["recentView"]);
      recentView.insert(0, event.toDocRef());

      int maxRV = 20;
      if (recentView.length > maxRV) {
        recentView = recentView.take(maxRV).toList();
      }

      transaction.update(user.toDocRef(), {
        "recentView": recentView,
      });
    });
  }

  reviewUser({required String id, required int rating}) {
    _firestore
        .collection("users")
        .doc(id)
        .update({"rating.$rating": FieldValue.increment(1)});
  }

  // * ----------  EVENT ----------

  addEvent({required Event event}) {
    _firestore.runTransaction((transaction) async {
      transaction.set(event.toDocRef(), event.toMap());
    });
  }

  updateEvent({required Event event}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(event.toDocRef(), event.toMap());
    });
  }

  updateEventPartial({required String id, required Map<String, dynamic> data}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(_firestore.collection("events").doc(id), data);
    });
  }

  removeEvent({required String id}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference =
          _firestore.collection(CollectionPath.events).doc(id);

      transaction.delete(documentReference);
    });
  }

  addEventMember({required Event event, required User user}) {
    _firestore.runTransaction((transaction) async {
      var doc = await event.toDocRef().get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<DocumentReference> member =
          List<DocumentReference>.from(data["member"]);
      member.add(user.toDocRef());

      transaction.update(event.toDocRef(), {
        "member": member,
      });
    });
  }

  removeEventMember({required Event event, required User user}) {
    _firestore.runTransaction((transaction) async {
      var doc = await event.toDocRef().get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<DocumentReference> member =
          List<DocumentReference>.from(data["member"]);
      member.remove(user.toDocRef());

      transaction.update(event.toDocRef(), {
        "member": member,
      });
    });
  }

  addEventMemberReview({required Event event, required User user}) {
    _firestore.runTransaction((transaction) async {
      var doc = await event.toDocRef().get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<DocumentReference> member =
          List<DocumentReference>.from(data["memberReviewed"]);
      member.add(user.toDocRef());

      transaction.update(event.toDocRef(), {
        "memberReviewed": member,
      });
    });
  }

  removeEventMemberReview({required Event event, required User user}) {
    _firestore.runTransaction((transaction) async {
      var doc = await event.toDocRef().get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<DocumentReference> member =
          List<DocumentReference>.from(data["memberReviewed"]);
      member.remove(user.toDocRef());

      transaction.update(event.toDocRef(), {
        "memberReviewed": member,
      });
    });
  }

  addChat({required String eventId, required Chat chat}) {
    _firestore.runTransaction((transaction) async {
      transaction.set(chat.toDocRef(eventId: eventId), chat.toMap());
    });
  }

  removeChat({required String eventId, required String chatId}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference = _firestore
          .collection(CollectionPath.events)
          .doc(eventId)
          .collection(SubcollectionPath.chats)
          .doc(chatId);

      transaction.delete(documentReference);
    });
  }

  // * ----------  CATEGORY ----------

  addCategory({required Category category}) {
    _firestore.runTransaction((transaction) async {
      transaction.set(category.toDocRef(), category.toMap());
    });
  }

  updateCategory({required Category category}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(category.toDocRef(), category.toMap());
    });
  }

  removeCategory({required String id}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference =
          _firestore.collection(CollectionPath.categories).doc(id);

      transaction.delete(documentReference);
    });
  }

  // * ----------  ROLE ----------

  addRole({required Role role}) {
    _firestore.runTransaction((transaction) async {
      transaction.set(role.toDocRef(), role.toMap());
    });
  }

  updateRole({required Role role}) {
    _firestore.runTransaction((transaction) async {
      transaction.update(role.toDocRef(), role.toMap());
    });
  }

  removeRole({required String id}) {
    _firestore.runTransaction((transaction) async {
      DocumentReference documentReference =
          _firestore.collection(CollectionPath.roles).doc(id);

      transaction.delete(documentReference);
    });
  }

  // --------------------

}
