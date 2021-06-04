import 'package:flutter/material.dart';
import 'package:users/screens/error/error_screen.dart';
import 'package:users/screens/home/home_screen.dart';
import 'package:users/screens/loading/loading_screen.dart';
import 'package:users/screens/login/login_screen.dart';
import 'package:users/screens/pick_location/pick_location_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
  LoadingScreen.routeName: (_) => LoadingScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),
  HomeScreen.routeName: (_) => HomeScreen(),
  PickLocationScreen.routeName: (_) => PickLocationScreen(),
};
