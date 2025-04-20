import 'package:flutter/material.dart';
import 'owner/home_owner.dart';
import 'admin/home_admin.dart';
import 'auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPref;


void main() async {

   
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: sharedPref.getString("id") == null
            ? LoginScreen()
            : sharedPref.getString("type") == "admin"
                ? HomeAdmin()
                : HomeOwner()
                );
  }
}
