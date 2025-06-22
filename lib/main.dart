import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rento/firebase_options.dart';
import 'package:rento/notifications/firebase_notification.dart';
import 'owner/home_owner.dart';
import 'admin/home_admin.dart';
import 'auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPref;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPref = await SharedPreferences.getInstance();
  await FirebaseNotifications().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: sharedPref.getString("id") == null
            ? LoginScreen()
            : sharedPref.getString("type") == "admin"
                ? HomeAdmin()
                : HomeOwner()
                );
  }
}
