import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users/components/custom_bottom_nav_bar.dart';
import 'package:users/screens/profile/manage_account_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your profile'),
      ),
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
                  Navigator.pushNamed(context, ManageAccountScreen.routeName),
              icon: Icon(Icons.account_circle_outlined),
              label: Text('Manage your account'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.favorite_border),
              label: Text('Favorites'),
            ),
            Divider(indent: 10, endIndent: 10, thickness: 1),
            TextButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.logout_outlined),
              label: Text('Sign out'),
              style:
                  TextButton.styleFrom(primary: Theme.of(context).errorColor),
            ),
          ],
        ),
      ),
    );
  }
}
