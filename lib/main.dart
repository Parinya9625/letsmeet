import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:letsmeet/letmeet_admin.dart';
import 'package:letsmeet/letmeet_app.dart';
import 'services/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // TODO : change recaptcha key
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );

  runApp(kIsWeb ? const LetsMeetAdmin() : const LetsMeetApp());
}
