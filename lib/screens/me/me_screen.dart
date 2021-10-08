import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users/widgets/custom_bottom_nav_bar.dart';

import 'edit_profile_screen.dart';

class MeScreen extends StatelessWidget {
  static const String routeName = '/me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage account')),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: TextButtonTheme(
        data: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.black87,
            alignment: Alignment.centerLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, EditProfileScreen.routeName),
              icon: Icon(Icons.edit_outlined),
              label: Text('Edit Your Default Booking Profile'),
            ),
            // TextButton.icon(
            //   onPressed: () {},
            //   icon: Icon(Icons.favorite_border),
            //   label: Text('My Likes'),
            // ),
            Divider(indent: 10, endIndent: 10, thickness: 1),
            TextButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.logout_outlined),
              label: Text('Sign Out'),
              style:
                  TextButton.styleFrom(primary: Theme.of(context).errorColor),
            ),
          ],
        ),
      ),
    );
  }
}
