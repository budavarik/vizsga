import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vizsga_feladat/providers/auth.dart';
import 'package:vizsga_feladat/screens/login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, Object> extractedUserData;

  @override
  Future<void> initState() {
    setState(() {
      getUserData();
    });
  }

   void getUserData() async {
    final pref = await SharedPreferences.getInstance();
    extractedUserData = json.decode(pref.getString('userData')) as Map<String, Object>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(extractedUserData != null ? extractedUserData['name'] : "Home"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Provider.of<Auth>(context, listen: false).logout();
            //Navigator.of(context).pushReplacementNamed("/");
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text("Logout"),
          color: Colors.green,
        ),
      ),
    );
  }
}
