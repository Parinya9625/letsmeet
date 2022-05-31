import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage;

  StorageService(this._firebaseStorage);

  String generateName(int length) {
    const char =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    var r = Random();
    return List.generate(length, (index) => char[r.nextInt(char.length)])
        .join();
  }

  Future<String> uploadProfileImage({required File file}) async {
    final storageRef = _firebaseStorage.ref();
    final imageRef =
        storageRef.child("images/profiles/${generateName(25)}.png");

    try {
      await imageRef.putFile(file);

      return imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      return e.message.toString();
    }
  }

  Future<String> uploadEventImage({required File file}) async {
    final storageRef = _firebaseStorage.ref();
    final imageRef =
        storageRef.child("images/events/${generateName(25)}.png");

    try {
      await imageRef.putFile(file);

      return imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      return e.message.toString();
    }
  }
}
