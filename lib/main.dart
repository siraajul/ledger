import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/reminder_service.dart';
import 'theme.dart';

// Re-exported so existing imports of 'main.dart' keep working.
export 'app.dart';
export 'screens/main_shell.dart';
export 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Web OAuth client of ledger-cea2a; Firebase verifies the ID token against it.
  await GoogleSignIn.instance.initialize(
    serverClientId: '770523884423-kf3t5fvgvg37aae1tniclh93qn2dd62s.apps.googleusercontent.com',
  );
  await ReminderService.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: kBg,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ExpenseTrackerApp());
}
