import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

enum AuthenticationResult {
  invalidEmail("The email address is badly formatted."),
  emailNotFound("No account found for this email."),
  wrongPassword("The password that you've entered is incorrect."),
  emailAlreadyInUse("This email already in use."),
  error("Unknow error. Please try again later."),
  googleSigninDismiss(""),
  success("");

  final String message;
  const AuthenticationResult(this.message);

  factory AuthenticationResult.fromCode(String code) {
    switch (code) {
      case "invalid-email":
        return AuthenticationResult.invalidEmail;
      case "user-not-found":
        return AuthenticationResult.emailNotFound;
      case "wrong-password":
        return AuthenticationResult.wrongPassword;
      case "email-already-in-use":
        return AuthenticationResult.emailAlreadyInUse;
      default:
        return AuthenticationResult.error;
    }
  }
}

class AuthResultWithUserInfo {
  final AuthenticationResult result;
  final String? uid;
  final String? name;
  final String? surname;
  final DateTime? birthday;
  final String? photoUrl;
  final DateTime? createdTime;

  AuthResultWithUserInfo({
    required this.result,
    this.uid,
    this.birthday,
    this.name,
    this.surname,
    this.photoUrl,
    this.createdTime,
  });
}

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>[PeopleServiceApi.userBirthdayReadScope]);

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<AuthenticationResult> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return AuthenticationResult.success;
    } on FirebaseAuthException catch (e) {
      return AuthenticationResult.fromCode(e.code);
    }
  }

  Future<AuthResultWithUserInfo> signUp(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return AuthResultWithUserInfo(
          result: AuthenticationResult.success, uid: userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResultWithUserInfo(
          result: AuthenticationResult.fromCode(e.code));
    }
  }

  Future<AuthenticationResult> isEmailExists({required String email}) async {
    try {
      List<String> signInMethod =
          await _firebaseAuth.fetchSignInMethodsForEmail(email);

      if (signInMethod.isNotEmpty) {
        return AuthenticationResult.emailAlreadyInUse;
      }
      return AuthenticationResult.emailNotFound;
    } on FirebaseAuthException catch (e) {
      return AuthenticationResult.fromCode(e.code);
    }
  }

  Future<AuthResultWithUserInfo> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      DateTime now = DateTime.now();
      var ageLimitDay = DateTime(now.year - 18, now.month, now.day);
      late UserCredential userCredential;
      final birthday = await getUserBirthday();
      if (birthday != null && birthday.isBefore(ageLimitDay)) {
        userCredential =
            await _firebaseAuth.signInWithCredential(authCredential);

        final displayName = userCredential.user!.displayName!.trim();
        final splitIndex = displayName.indexOf(" ");
        final name = splitIndex != -1
            ? displayName.substring(0, splitIndex)
            : displayName;
        final surname = splitIndex != -1
            ? displayName.substring(splitIndex, displayName.length)
            : "";

        return AuthResultWithUserInfo(
          result: AuthenticationResult.success,
          uid: userCredential.user!.uid,
          birthday: birthday,
          name: name.trim(),
          surname: surname.trim(),
          photoUrl: userCredential.user!.photoURL,
          createdTime: userCredential.user!.metadata.creationTime,
        );
      } else {
        signOut();
        return AuthResultWithUserInfo(result: AuthenticationResult.error);
      }
    } on FirebaseAuthException catch (e) {
      return AuthResultWithUserInfo(
          result: AuthenticationResult.fromCode(e.code));
    } catch (e) {
      return AuthResultWithUserInfo(
          result: AuthenticationResult.googleSigninDismiss);
    }
  }

  Future<DateTime?> getUserBirthday() async {
    var client = (await _googleSignIn.authenticatedClient())!;
    PeopleServiceApi peopleServiceApi = PeopleServiceApi(client);

    Person person = await peopleServiceApi.people
        .get("people/me", personFields: "birthdays");

    Date? birthday = person.birthdays?.last.date;
    if (birthday != null) {
      return DateTime(birthday.year!, birthday.month!, birthday.day!);
    }

    return null;
  }

  Future<AuthenticationResult> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      return AuthenticationResult.success;
    } on FirebaseAuthException catch (e) {
      return AuthenticationResult.fromCode(e.code);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
