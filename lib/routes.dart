import 'package:flutter/material.dart';
import 'package:users/screens/error/error_screen.dart';
import 'package:users/screens/home/home_screen.dart';
import 'package:users/screens/loading/loading_screen.dart';
import 'package:users/screens/login/login_screen.dart';

// Navigator.pushNamed(context, SignInScreen.routeName)

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
  LoadingScreen.routeName: (_) => LoadingScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),
  HomeScreen.routeName: (_) => HomeScreen(),
};
