import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'theme.dart';

// Re-exported so existing imports of 'main.dart' keep working.
export 'app.dart';
export 'screens/main_shell.dart';
export 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kBg,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ExpenseTrackerApp());
}
