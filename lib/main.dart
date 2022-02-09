import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vizsga_feladat/providers/auth.dart';
import 'package:vizsga_feladat/screens/home_Screen.dart';
import 'package:vizsga_feladat/screens/login_Screen.dart';
import 'package:vizsga_feladat/screens/splash_Screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Auth(),
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.parentData.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryautoLogin(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : LoginScreen(),
                ),
        ),
      ),
    );
  }
}
