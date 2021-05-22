import 'package:flutter/material.dart';
import 'package:users/routes.dart';
import 'package:users/screens/login/login_screen.dart';
import 'package:users/theme.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyWellness',
      theme: theme(),
      initialRoute: LoginScreen.routeName,
      routes: routes,
    );
  }
}
