import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users/components/custom_bottom_nav_bar.dart';

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
              onPressed: () {},
              icon: Icon(Icons.account_circle_outlined),
              label: Text('Manage your account'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.favorite_border),
              label: Text('Favorites'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.reviews_outlined),
              label: Text('Reviews'),
            ),
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
