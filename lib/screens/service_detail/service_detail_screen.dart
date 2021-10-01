import 'package:flutter/material.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/utils/time_slot_is_booked.dart';
import 'package:users/widgets/appointment_scheduler.dart';

import 'create_booking_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  ServiceDetailScreen({
    Key? key,
    required this.serviceId,
    required this.service,
  }) : super(key: key);

  final String serviceId;
  final DbNearbyService service;

  @override
  Widget build(BuildContext context) {
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
            labelColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Tab(text: 'schedule'.toUpperCase()),
              Tab(text: 'information'.toUpperCase()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScheduleTabView(
              serviceId: serviceId,
              service: service,
            ),
            Container()
          ],
        ),
      ),
    );
  }
}

class ScheduleTabView extends StatelessWidget {
  const ScheduleTabView({
    Key? key,
    required this.serviceId,
    required this.service,
  }) : super(key: key);

  final String serviceId;
  final DbNearbyService service;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: AppointmentScheduler(
            validator: (value) async {
              if (await timeSlotIsBooked(value))
                return 'You already have an appointment at this time';
            },
            onTimeSlotSelect: (selectedDateTime) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateBookingScreen(
                  serviceId: serviceId,
                  bookedService: service,
                  selectedDateTime: selectedDateTime,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
