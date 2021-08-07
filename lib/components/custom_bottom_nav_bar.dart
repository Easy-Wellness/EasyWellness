import 'package:flutter/material.dart';
import 'package:users/screens/booking_list/booking_list_screen.dart';
import 'package:users/screens/chat_list/chat_list_screen.dart';
import 'package:users/screens/explore/explore_screen.dart';
import 'package:users/screens/me/me_screen.dart';

final List<Widget> _rootScreens = [
  ExploreScreen(),
  BookingListScreen(),
  ChatListScreen(),
  MeScreen(),
];

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialIndex = ModalRoute.of(context)!.settings.arguments as int?;
    final currentIndex = initialIndex ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[350]!)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey[750],
        selectedItemColor: Theme.of(context).accentColor,
        onTap: (index) => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            settings: RouteSettings(arguments: index),
            pageBuilder: (_, __, ___) => _rootScreens[index],
            transitionDuration: const Duration(milliseconds: 100),

            ///  After navigating from route A to route B, the widgets in
            /// route B will fade in (go from opacity 0 to 1) gradually
            transitionsBuilder: (_, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            label: 'Explore',
            icon: Icon(Icons.search_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Bookings',
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Chats',
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Me',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
          )
        ],
      ),
    );
  }
}
