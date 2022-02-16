import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vizsga_feladat/providers/auth.dart';
import 'package:vizsga_feladat/screens/login_Screen.dart';
import 'package:vizsga_feladat/screens/select_kid_screen.dart';
import 'package:vizsga_feladat/screens/kid_view_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, Object> extractedUserData;
  bool autoLogin = false;

  @override
  void initState() {
    startScreen();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (contex) => Auth(),
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white70,
            dialogBackgroundColor: Colors.grey,
            backgroundColor: Colors.grey,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.parentData.isAuth
              ? LoginScreen()
              : FutureBuilder(
                  future: auth.tryautoLogin(),
                  builder: (ctx, snapshot) =>
//                      (snapshot.connectionState == ConnectionState.waiting
                        (autoLogin
                          ? (extractedUserData['kidName'] != null && extractedUserData['kidName'] != "" ? kidViewScreen() : SelectKidScreen())
                          : LoginScreen()),
                ),
        ),
      ),
    );
  }

  Future<void> startScreen() async {
    final pref = await SharedPreferences.getInstance().then((pref) {
      if (pref.containsKey('userData')) {
        extractedUserData =
        json.decode(pref.getString('userData')) as Map<String, Object>;
        autoLogin = true;
      } else{
        autoLogin = false;
      }
    });

  }
}
