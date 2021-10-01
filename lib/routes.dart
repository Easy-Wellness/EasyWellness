import 'package:flutter/material.dart';
import 'package:users/screens/appointment_list/appointment_list_screen.dart';
import 'package:users/screens/appointment_list/cancel_or_reschedule_screen.dart';
import 'package:users/screens/chat_list/chat_list_screen.dart';
import 'package:users/screens/me/me_screen.dart';

import 'screens/error/error_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/explore/search_services_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/me/edit_profile_screen.dart';
import 'screens/service_detail/create_booking_screen.dart';
import 'screens/service_detail/service_detail_screen.dart';
import 'widgets/pick_location_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
  LoadingScreen.routeName: (_) => LoadingScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),
  PickLocationScreen.routeName: (_) => PickLocationScreen(),

  /// Sub-screens of the root Explore Screen
  ExploreScreen.routeName: (_) => ExploreScreen(),
  SearchServicesScreen.routeName: (_) => SearchServicesScreen(),

  /// Sub-screens of the Service Detail Screen
  ServiceDetailScreen.routeName: (_) => ServiceDetailScreen(),
  CreateBookingScreen.routeName: (_) => CreateBookingScreen(),

  /// Sub-screens of the root Appointment List Screen
  AppointmentListScreen.routeName: (_) => AppointmentListScreen(),
  CancelOrRescheduleScreen.routeName: (_) => CancelOrRescheduleScreen(),

  /// Sub-screens of the root Chat List Screen
  ChatListScreen.routeName: (_) => ChatListScreen(),

  /// Sub-screens of the root Me Screen
  MeScreen.routeName: (_) => MeScreen(),
  EditProfileScreen.routeName: (_) => EditProfileScreen(),
};
