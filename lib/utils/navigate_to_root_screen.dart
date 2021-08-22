import 'package:flutter/material.dart';
import 'package:users/screens/appointment_list/appointment_list_screen.dart';
import 'package:users/screens/chat_list/chat_list_screen.dart';
import 'package:users/screens/explore/explore_screen.dart';
import 'package:users/screens/me/me_screen.dart';

final List<Widget> _rootScreens = [
  ExploreScreen(),
  AppointmentListScreen(),
  ChatListScreen(),
  MeScreen(),
];

void navigateToRootScreen(BuildContext context, int screenIndex) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      settings: RouteSettings(arguments: screenIndex),
      pageBuilder: (_, __, ___) => _rootScreens[screenIndex],
      transitionDuration: const Duration(milliseconds: 100),

      ///  After navigating from route A to route B, the widgets in
      /// route B will fade in (go from opacity 0 to 1) gradually
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
