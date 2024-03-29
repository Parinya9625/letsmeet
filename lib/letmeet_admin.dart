import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/feedback.dart' as lm;
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/storage.dart';
import 'package:letsmeet/services/theme_provider.dart';
import 'package:letsmeet/style.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:letsmeet/pages/admin/sign_in_page.dart';
import 'package:letsmeet/pages/admin/main_page.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/event.dart';
import 'package:letsmeet/models/report.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/models/ban.dart';
import 'package:letsmeet/models/user.dart' as lm;
import 'package:intl/intl.dart';

class LetsMeetAdmin extends StatefulWidget {
  const LetsMeetAdmin({Key? key}) : super(key: key);

  @override
  State<LetsMeetAdmin> createState() => _LetsMeetAdminState();
}

class _LetsMeetAdminState extends State<LetsMeetAdmin> {
  late StreamSubscription<User?> streamUserAuthState;
  final navigatorKey = GlobalKey<NavigatorState>();
  final scaffoldMessangerKey = GlobalKey<ScaffoldMessengerState>();
  List<SingleChildWidget> afterAuthProviders = [];

  void signOut() {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
  }

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

  showMaterialBanner(String text) {
    scaffoldMessangerKey.currentState!.showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(16),
        content: Text(
          text,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
    streamUserAuthState =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        setState(() {
          afterAuthProviders.clear();
        });

        navigatorKey.currentState!
            .pushNamedAndRemoveUntil("/signin", (route) => false);
      } else {
        setState(() {
          afterAuthProviders.addAll(
            [
              // Add lmUser to provider
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

              // stream available after login
              StreamProvider<List<Ban>>(
                create: (context) =>
                    context.read<CloudFirestoreService>().streamBans,
                initialData: const [],
              ),
              StreamProvider<List<Category>>(
                create: (context) =>
                    context.read<CloudFirestoreService>().streamCategories,
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
              StreamProvider<List<Role>>(
                create: (context) =>
                    context.read<CloudFirestoreService>().streamRoles,
                initialData: const [],
              ),
              StreamProvider<List<lm.Feedback>>(
                create: (context) =>
                    context.read<CloudFirestoreService>().streamFeedbacks,
                initialData: const [],
              ),
            ],
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
            lmUser.getRole.then((role) {
              // check admin permission
              if (role.permission.isAdmin) {
                navigatorKey.currentState!
                    .pushNamedAndRemoveUntil("/home", (route) => false);
                userStream.cancel();
              } else {
                FirebaseAuth.instance.signOut();
                GoogleSignIn().signOut();
                userStream.cancel();
                showMaterialBanner("Permission Denied");
              }
            });
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
    });

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
        ...afterAuthProviders,
        Provider<GlobalKey<NavigatorState>>(
          create: (_) => navigatorKey,
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(defaultMode: ThemeMode.system),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return materialApp(
              themeMode: themeProvider.mode,
            );
          },
        ),
      ),
    );
  }

  Widget materialApp({ThemeMode themeMode = ThemeMode.system}) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessangerKey,
      title: 'LetsMeet Admin',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routes: {
        "/": (context) => const LoadingPage(),
        "/signin": (context) => const SignInPage(),
        "/home": (context) => const MainPage(),
      },
      onGenerateRoute: (settings) {
        return null;
      },
      initialRoute: "/",
      builder: (BuildContext context, Widget? child) {
        return Shimmer(
          colors: [
            Theme.of(context).extension<LetsMeetColor>()!.shimmerBase,
            Theme.of(context).extension<LetsMeetColor>()!.shimmerRun,
            Theme.of(context).extension<LetsMeetColor>()!.shimmerBase,
          ],
          child: child,
        );
      },
    );
  }
}

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
