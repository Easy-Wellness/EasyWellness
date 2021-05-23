import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  static String routeName = '/error';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
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
