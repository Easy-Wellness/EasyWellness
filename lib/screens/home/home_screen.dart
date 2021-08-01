import 'package:flutter/material.dart';
import 'package:users/components/bottom_navbar.dart';
import 'package:users/screens/home/search_services_form.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Body(),
        bottomNavigationBar: BottomNavbar(),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchServicesForm(),
    );
  }
}
