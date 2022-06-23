import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:letsmeet/components/shimmer.dart';
import 'package:letsmeet/models/category.dart';
import 'package:letsmeet/models/role.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/services/storage.dart';
import 'package:letsmeet/style.dart';
import 'package:provider/provider.dart';
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

class LetsMeetApp extends StatelessWidget {
  const LetsMeetApp({Key? key}) : super(key: key);

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
      ],
      child: Shimmer(
        child: MaterialApp(
          title: 'LetsMeet',
          theme: lightTheme,
          home: kIsWeb ? const ForWeb() : const ForMobile(),
        ),
      ),
    );
  }
}

// ??: temporary for web
class ForWeb extends StatelessWidget {
  const ForWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("For Web")),
      body: Column(),
    );
  }
}

// ?? temporary for mobile
class ForMobile extends StatefulWidget {
  const ForMobile({Key? key}) : super(key: key);

  @override
  State<ForMobile> createState() => _ForMobileState();
}

class _ForMobileState extends State<ForMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("For Mobile"),
      ),
      body: Column(),
    );
  }
}
