import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/feedback.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/models/ban.dart';
import 'package:letsmeet/models/chat.dart';
import 'package:letsmeet/models/report.dart';

class CollectionPath {
  CollectionPath._();

  static const String users = "users";
  static const String events = "events";
  static const String reports = "reports";
  static const String bans = "bans";
  static const String categories = "categories";
  static const String roles = "roles";
  static const String feedbacks = "feedbacks";
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

  Stream<List<Feedback>> get streamFeedbacks => _firestore
      .collection(CollectionPath.feedbacks)
      .orderBy("createdTime", descending: true)
      .snapshots()
      .map((feedbacks) => feedbacks.docs
          .map((doc) => Feedback.fromFirestore(doc: doc))
          .toList());

  // * ----------  BAN ----------

  addBan({required Ban ban}) {
    ban.toDocRef().set(ban.toMap());
  }

  updateBan({required String id, required Map<String, dynamic> data}) {
    _firestore.collection(CollectionPath.bans).doc(id).update(data);
  }

  removeBan({required String id}) {
    _firestore.collection(CollectionPath.bans).doc(id).delete();
  }

  // * ----------  REPORT ----------

  Future<bool> addReport({required Report report}) {
    return _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(report.toDocRef());

      if (doc.exists) {
        // Merge new report to latest report data
        Report latestReport = Report.fromFirestore(doc: doc);
        List<String> reason = latestReport.reason;

        reason.addAll(report.reason);

        transaction.update(report.toDocRef(), {
          "reason": reason,
          "count": FieldValue.increment(1),
        });
      } else {
        // Create new report
        report.toDocRef().set(report.toMap());
      }

      return true;
    }).onError((error, stackTrace) => false);
  }

  removeReport({required String id}) {
    _firestore.collection(CollectionPath.reports).doc(id).delete();
  }

  // * ----------  USER ----------

  addUser({required User user}) {
    user.toDocRef().set(user.toMap());
  }

  updateUser({required String id, required Map<String, dynamic> data}) {
    _firestore.collection(CollectionPath.users).doc(id).update(data);
  }

  removeUser({required String id}) {
    _firestore.collection(CollectionPath.users).doc(id).delete();
  }

  addUserRecentView({required User user, required String eventId}) {
    _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(user.toDocRef());
      User latestUser = User.fromFirestore(doc: doc);
      var recentView = latestUser.recentView;

      if (!recentView.any((event) => event.id == eventId)) {
        // New event
        recentView.insert(
            0, _firestore.collection(CollectionPath.events).doc(eventId));

        int maxRV = 20;
        recentView = recentView.take(maxRV).toList();

        transaction.update(user.toDocRef(), {
          "recentView": recentView,
        });
      } else {
        // Already in recent view
        if (recentView.first.id != eventId) {
          // event not in first index
          recentView.removeWhere((event) => event.id == eventId);
          recentView.insert(
              0, _firestore.collection(CollectionPath.events).doc(eventId));

          transaction.update(user.toDocRef(), {
            "recentView": recentView,
          });
        }
      }
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
    event.toDocRef().set(event.toMap());
  }

  updateEvent({required String id, required Map<String, dynamic> data}) {
    _firestore.collection(CollectionPath.events).doc(id).update(data);
  }

  Future<void> removeEvent({required String id}) async {
    return _firestore
        .collection(CollectionPath.events)
        .doc(id)
        .collection(SubcollectionPath.chats)
        .get()
        .then((querySnapshot) {
      for (var snapshot in querySnapshot.docs) {
        snapshot.reference.delete();
      }
    }).then((_) {
      return _firestore.collection(CollectionPath.events).doc(id).delete();
    });
  }

  Future<bool> addEventMember(
      {required Event event, required User user}) async {
    return _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(event.toDocRef());
      Event latestEvent = Event.fromFirestore(doc: doc);

      if (latestEvent.member.length < latestEvent.maxMember) {
        // Can join event
        event.toDocRef().update({
          "member": FieldValue.arrayUnion([user.toDocRef()]),
        });
        return true;
      } else {
        // Event have max member
        return false;
      }
    }).onError((error, stackTrace) => false);
  }

  Future<bool> removeEventMember(
      {required Event event, required User user}) async {
    event.toDocRef().update({
      "member": FieldValue.arrayRemove([user.toDocRef()])
    });
    return true;
  }

  addEventMemberReview({required Event event, required User user}) {
    event.toDocRef().update({
      "memberReviewed": FieldValue.arrayUnion([user.toDocRef()])
    });
  }

  addChat({required String eventId, required Chat chat}) {
    chat.toDocRef(eventId: eventId).set(chat.toMap());
  }

  removeChat({required String eventId, required String chatId}) {
    _firestore
        .collection(CollectionPath.events)
        .doc(eventId)
        .collection(SubcollectionPath.chats)
        .doc(chatId)
        .delete();
  }

  // * ----------  CATEGORY ----------

  addCategory({required Category category}) {
    category.toDocRef().set(category.toMap());
  }

  updateCategory({required String id, required Map<String, dynamic> data}) {
    _firestore.collection(CollectionPath.categories).doc(id).update(data);
  }

  removeCategory({required String id}) {
    _firestore.collection(CollectionPath.categories).doc(id).delete();
  }

  // * ----------  ROLE ----------

  addRole({required Role role}) {
    role.toDocRef().set(role.toMap());
  }

  updateRole({required String id, required Map<String, dynamic> data}) {
    _firestore.collection(CollectionPath.roles).doc(id).update(data);
  }

  removeRole({required String id}) {
    _firestore.collection(CollectionPath.roles).doc(id).delete();
  }

  // * ----------  FEEDBACK ----------
  addFeedback({required Feedback feedback}) {
    feedback.toDocRef().set(feedback.toMap());
  }

  removeFeedback({required String id}) {
    _firestore.collection(CollectionPath.feedbacks).doc(id).delete();
  }

  // --------------------

}
