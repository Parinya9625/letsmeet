import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/pages/create_edit_event_page.dart';
import 'package:letsmeet/pages/edit_profile_page.dart';
import 'package:letsmeet/pages/forgot_password_page.dart';
import 'package:letsmeet/pages/main_page.dart';
import 'package:letsmeet/pages/review_user_page.dart';
import 'package:letsmeet/pages/setup_profile_page.dart';
import 'package:letsmeet/pages/sign_in_page.dart';
import 'package:letsmeet/pages/sign_up_page.dart';
import 'package:letsmeet/pages/welcome_page.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/storage.dart';
import 'package:letsmeet/style.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'models/event.dart';
import 'services/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'models/report.dart';
import 'models/ban.dart';
import 'models/user.dart' as lm;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // TODO : change recaptcha key
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );

  runApp(const LetsMeetApp());
}

class LetsMeetApp extends StatefulWidget {
  const LetsMeetApp({Key? key}) : super(key: key);

  @override
  State<LetsMeetApp> createState() => _LetsMeetAppState();
}

class _LetsMeetAppState extends State<LetsMeetApp> {
  late StreamSubscription<User?> streamUserAuthState;
  final navigatorKey = GlobalKey<NavigatorState>();
  final scaffoldMessangerKey = GlobalKey<ScaffoldMessengerState>();
  List<SingleChildWidget> userProviders = [];

  showBanDialog(Ban ban) {
    scaffoldMessangerKey.currentState!.showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(16),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Your account got banned!",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Banned time: ${DateFormat("EEE, dd MMM y, HH:mm").format(ban.banTime)}",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Reason: ${ban.reason}",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        leading:
            const Icon(Icons.warning_rounded, color: Colors.white, size: 48),
        backgroundColor: Theme.of(context).errorColor,
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(16, 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: scaffoldMessangerKey.currentState!.clearMaterialBanners,
            child: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // Check if user login and update page to user state
    streamUserAuthState = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        if (user == null) {
          // don't login
          navigatorKey.currentState!.pushReplacementNamed("/welcome");
        } else {
          setState(() {
            // Add lmUser to provider
            userProviders.add(
              StreamProvider<lm.User?>(
                create: (context) => FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .snapshots()
                    .map((doc) =>
                        doc.exists ? lm.User.fromFirestore(doc: doc) : null),
                // set init data with only user [id] for fix data is too slow
                // to load by provider
                initialData: lm.User.createWithID(
                  id: user.uid,
                  birthday: DateTime.now(),
                  image: "",
                  name: "",
                  surname: "",
                ),
              ),
            );
          });

          final userSnapshot = FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots();

          final userStream = userSnapshot.listen(null);
          userStream.onData((doc) {
            if (doc.data() != null) {
              lm.User lmUser = lm.User.fromFirestore(doc: doc);

              // if user finish setup profile
              if (lmUser.isFinishSetup) {
                // app home page
                navigatorKey.currentState!.pushNamedAndRemoveUntil(
                    "/", (Route<dynamic> route) => false);
                userStream.cancel();
              } else {
                // if user don't finish setup proifile
                navigatorKey.currentState!.pushNamedAndRemoveUntil(
                    "/signup/setup", (Route<dynamic> route) => false);
              }
            }
          });

          // listen for current user ban status
          final banSnapshot = FirebaseFirestore.instance
              .collection("bans")
              .doc(user.uid)
              .snapshots();
          banSnapshot.listen((doc) {
            if (doc.data() != null) {
              FirebaseAuth.instance.signOut();
              GoogleSignIn().signOut();

              Ban ban = Ban.fromFirestore(doc: doc);
              showBanDialog(ban);
            }
          });
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    streamUserAuthState.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...userProviders,
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        Provider<StorageService>(
          create: (_) => StorageService(FirebaseStorage.instance),
        ),
        Provider<CloudFirestoreService>(
          create: (_) => CloudFirestoreService(FirebaseFirestore.instance),
        ),
        StreamProvider<List<Ban>>(
          create: (context) => context.read<CloudFirestoreService>().streamBans,
          initialData: const [],
        ),
        StreamProvider<List<Report>>(
          create: (context) =>
              context.read<CloudFirestoreService>().streamReports,
          initialData: const [],
        ),
        StreamProvider<List<lm.User>>(
          create: (context) =>
              context.read<CloudFirestoreService>().streamUsers,
          initialData: const [],
        ),
        StreamProvider<List<Event>>(
          create: (context) =>
              context.read<CloudFirestoreService>().streamEvents,
          initialData: const [],
        ),
        StreamProvider<List<Category>>(
          create: (context) =>
              context.read<CloudFirestoreService>().streamCategories,
          initialData: const [],
        ),
        StreamProvider<List<Role>>(
          create: (context) =>
              context.read<CloudFirestoreService>().streamRoles,
          initialData: const [],
        ),
        Provider<GlobalKey<NavigatorState>>(
          create: (_) => navigatorKey,
        ),
      ],
      child: Shimmer(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessangerKey,
          title: 'LetsMeet',
          theme: lightTheme,
          routes: {
            "/startup": (context) => const LoadingPage(),
            "/welcome": (context) => const WelcomePage(),
            "/signup": (context) => const SignUpPage(),
            "/signup/setup": (context) => const SetupProfilePage(),
            "/signin": (context) => const SignInPage(),
            "/signin/forgot": (context) => const ForgotPasswordPage(),
            "/": (context) => const MainPage(),
            "/event/create": (context) => const CreateEditEventPage(),
            "/profile/edit": (context) =>
                EditProfilePage(user: context.read<lm.User?>()!),
          },
          onGenerateRoute: (settings) {
            Widget? page;
            switch (settings.name) {
              case "/event/edit":
                page = CreateEditEventPage(event: settings.arguments as Event?);
                break;
              case "/event/review":
                page = ReviewUserPage(event: settings.arguments as Event);
                break;
            }

            if (page != null) {
              return MaterialPageRoute(builder: (context) => page!);
            }
            return null;
          },
          initialRoute: "/startup",
          // home: kIsWeb ? const ForWeb() : const ForMobile(),
        ),
      ),
    );
  }
}

// Temp Page (can be splash screen?)
class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
