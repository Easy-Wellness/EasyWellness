import 'package:flutter/material.dart';

import 'screens/appointment_list/appointment_list_screen.dart';
import 'screens/chat_list/chat_list_screen.dart';
import 'screens/error/error_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/me/edit_profile_screen.dart';
import 'screens/me/me_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
  LoadingScreen.routeName: (_) => LoadingScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),

  /// Sub-screens of the root Explore Screen
  ExploreScreen.routeName: (_) => ExploreScreen(),

  /// Sub-screens of the root Appointment List Screen
  AppointmentListScreen.routeName: (_) => AppointmentListScreen(),

  /// Sub-screens of the root Chat List Screen
  ChatListScreen.routeName: (_) => ChatListScreen(),

  /// Sub-screens of the root Me Screen
  MeScreen.routeName: (_) => MeScreen(),
  EditProfileScreen.routeName: (_) => EditProfileScreen(),
};
