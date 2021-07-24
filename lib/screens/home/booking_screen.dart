import 'package:flutter/material.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';

class BookingScreen extends StatelessWidget {
  static String routeName = '/create_booking';

  @override
  Widget build(BuildContext context) {
    final service = (ModalRoute.of(context)!.settings.arguments
        as Map<String, Object>)['service'] as DbNearbyService;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            service.placeName,
            style: TextStyle(fontSize: 16),
          ),
          bottom: TabBar(
            unselectedLabelColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).accentColor,
            tabs: [
              Tab(text: 'schedule'.toUpperCase()),
              Tab(text: 'overview'.toUpperCase()),
            ],
          ),
        ),
        body: TabBarView(children: [Container(), Container()]),
      ),
    );
  }
}
