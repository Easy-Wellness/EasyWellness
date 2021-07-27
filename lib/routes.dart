import 'package:flutter/material.dart';
import 'package:users/screens/error/error_screen.dart';
import 'package:users/screens/home/create_booking_screen.dart';
import 'package:users/screens/home/schedule_booking_screen.dart';
import 'package:users/screens/home/home_screen.dart';
import 'package:users/screens/loading/loading_screen.dart';
import 'package:users/screens/login/login_screen.dart';
import 'package:users/screens/home/pick_location_screen.dart';
import 'package:users/screens/home/search_services_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
  LoadingScreen.routeName: (_) => LoadingScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),
  HomeScreen.routeName: (_) => HomeScreen(),
  PickLocationScreen.routeName: (_) => PickLocationScreen(),
  SearchServicesScreen.routeName: (_) => SearchServicesScreen(),
  ScheduleBookingScreen.routeName: (_) => ScheduleBookingScreen(),
  CreateBookingScreen.routeName: (_) => CreateBookingScreen(),
};
