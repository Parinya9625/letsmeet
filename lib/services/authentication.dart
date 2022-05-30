import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>[PeopleServiceApi.userBirthdayReadScope]);

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.idTokenChanges();

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return "";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<String> signUp(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      return "";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await checkUserAge().then((validUser) async {
        if (validUser) {
          await _firebaseAuth.signInWithCredential(authCredential);
        } else {
          signOut();
        }
      });

      return "";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<bool> checkUserAge() async {
    var client = (await _googleSignIn.authenticatedClient())!;
    PeopleServiceApi peopleServiceApi = PeopleServiceApi(client);

    Person person = await peopleServiceApi.people
        .get("people/me", personFields: "birthdays");

    DateTime now = DateTime.now();
    var year = person.birthdays?.last.date?.year;

    if (year != null && now.year - year >= 18) return true;
    return false;
  }

  Future<String> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      return "";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
