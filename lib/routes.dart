import 'package:flutter/material.dart';
import 'package:users/screens/login/login_screen.dart';

// Navigator.pushNamed(context, SignInScreen.routeName)

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => LoginScreen(),
};
