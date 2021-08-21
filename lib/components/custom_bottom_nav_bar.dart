import 'package:flutter/material.dart';
import 'package:users/utils/navigate_to_root_screen.dart';

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
        onTap: (index) => navigateToRootScreen(context, index),
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
