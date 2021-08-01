import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:users/screens/home/home_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavyBar(
      selectedIndex: _selectedIndex,
      showElevation: true, // use this to remove appBar's elevation
      onItemSelected: (index) => setState(() => _selectedIndex = index),
      items: [
        _buildNavBarItem(
          context,
          title: 'Search',
          iconData: Icons.search_outlined,
          routeName: HomeScreen.routeName,
        ),
        _buildNavBarItem(
          context,
          title: 'Bookings',
          iconData: Icons.event_note_outlined,
          routeName: HomeScreen.routeName,
        ),
        _buildNavBarItem(
          context,
          title: 'Chats',
          iconData: Icons.chat_outlined,
          routeName: HomeScreen.routeName,
        ),
        _buildNavBarItem(
          context,
          title: 'You',
          iconData: Icons.account_circle_outlined,
          routeName: HomeScreen.routeName,
        )
      ],
    );
  }
}

BottomNavyBarItem _buildNavBarItem(
  BuildContext context, {
  required String title,
  required IconData iconData,
  required String routeName,
}) {
  return BottomNavyBarItem(
    icon: Icon(iconData),
    title: TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, routeName),
      child: Text(title),
    ),
    activeColor: Theme.of(context).accentColor,
    textAlign: TextAlign.center,
  );
}
