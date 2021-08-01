import 'package:flutter/material.dart';

import 'screens/error/error_screen.dart';
import 'screens/explore/create_booking_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/explore/pick_location_screen.dart';
import 'screens/explore/schedule_booking_screen.dart';
import 'screens/explore/search_services_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
  LoadingScreen.routeName: (_) => LoadingScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),
  ExploreScreen.routeName: (_) => ExploreScreen(),
  PickLocationScreen.routeName: (_) => PickLocationScreen(),
  SearchServicesScreen.routeName: (_) => SearchServicesScreen(),
  ScheduleBookingScreen.routeName: (_) => ScheduleBookingScreen(),
  CreateBookingScreen.routeName: (_) => CreateBookingScreen(),
};
