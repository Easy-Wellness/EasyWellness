import 'package:flutter/material.dart';
import 'package:users/screens/appointment_list/appointment_list_screen.dart';
import 'package:users/screens/chat_room_list/chat_room_list_screen.dart';
import 'package:users/screens/explore/explore_screen.dart';
import 'package:users/screens/me/me_screen.dart';

enum RootScreen {
  exploreScreen,
  appointmentListScreen,
  chatRoomListScreen,
  meScreen,
}

void navigateToRootScreen(BuildContext context, RootScreen screen) {
  /// Keep disposing screens until meeting the first screen
  Navigator.of(context).popUntil((route) => route.isFirst);
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      /// Tells the [CustomBottomNavBar] of the new screen the index of
      /// the root screen we'tr trying to navigate to
      settings: RouteSettings(arguments: {'rootScreenIndex': screen.index}),
      pageBuilder: (_, __, ___) => _getRootScreenWidget(screen),
      transitionDuration: const Duration(milliseconds: 100),

      ///  After navigating from route A to route B, the widgets in
      /// route B will fade in (go from opacity 0 to 1) gradually
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

Widget _getRootScreenWidget(RootScreen rootScreen) {
  switch (rootScreen) {
    case RootScreen.exploreScreen:
      return ExploreScreen();
    case RootScreen.appointmentListScreen:
      return AppointmentListScreen();
    case RootScreen.chatRoomListScreen:
      return ChatRoomListScreen();
    case RootScreen.meScreen:
      return MeScreen();
  }
}
