import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:letsmeet/letmeet_admin.dart';
import 'package:letsmeet/letmeet_app.dart';
import 'package:letsmeet/url_strategy/url_strategy.dart';
import 'services/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: '6LdVsnQhAAAAANXtgq6HgQxLpfh-fQQo9RFNipKO',
  );

  usePathUrlStrategy();
  runApp(kIsWeb ? const LetsMeetAdmin() : const LetsMeetApp());
}
