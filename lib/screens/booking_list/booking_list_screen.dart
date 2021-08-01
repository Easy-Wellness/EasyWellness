import 'package:flutter/material.dart';
import 'package:users/components/custom_bottom_nav_bar.dart';

class BookingListScreen extends StatelessWidget {
  static const String routeName = '/booking_list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your bookings'),
      ),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
