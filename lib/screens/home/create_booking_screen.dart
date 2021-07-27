import 'package:flutter/material.dart';

class CreateBookingScreen extends StatelessWidget {
  static const String routeName = '/create_booking';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking summary'),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
