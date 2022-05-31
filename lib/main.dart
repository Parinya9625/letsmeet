import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:letsmeet/services/authentication.dart';
import 'package:provider/provider.dart';
import 'services/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
            initialData: null),
      ],
      child: MaterialApp(
        title: 'LetsMeet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: kIsWeb ? const ForWeb() : const ForMobile(),
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
      body: Column(
        children: const [],
      ),
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
      body: Column(
        children: const [],
      ),
    );
  }
}
