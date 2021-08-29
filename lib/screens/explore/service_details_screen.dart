import 'package:flutter/material.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/widgets/appointment_scheduler.dart';

import 'create_booking_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  static const String routeName = '/schedule_booking';

  @override
  Widget build(BuildContext context) {
    final service = (ModalRoute.of(context)!.settings.arguments
        as Map<String, Object>)['service'] as DbNearbyService;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            service.placeName,
            style: const TextStyle(fontSize: 16),
          ),
          bottom: TabBar(
            unselectedLabelColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).accentColor,
            tabs: [
              Tab(text: 'schedule'.toUpperCase()),
              Tab(text: 'information'.toUpperCase()),
            ],
          ),
        ),
        body: TabBarView(children: [ScheduleTabView(), Container()]),
      ),
    );
  }
}

class ScheduleTabView extends StatefulWidget {
  @override
  _ScheduleTabViewState createState() => _ScheduleTabViewState();
}

class _ScheduleTabViewState extends State<ScheduleTabView> {
  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)!.settings.arguments as Map<String, Object>);
    final serviceId = args['serviceId'] as String;
    final service = args['service'] as DbNearbyService;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: AppointmentScheduler(
          onTimeSlotSelect: (selectedDateTime) => Navigator.pushNamed(
            context,
            CreateBookingScreen.routeName,
            arguments: {
              'serviceId': serviceId,
              'bookedService': service,
              'selectedDateTime': selectedDateTime,
            },
          ),
        ),
      ),
    );
  }
}
