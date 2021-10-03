import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/models/place/db_place.model.dart';
import 'package:users/utils/time_slot_is_booked.dart';
import 'package:users/widgets/appointment_scheduler.dart';

import 'create_booking_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  ServiceDetailScreen({
    Key? key,
    required this.placeId,
    required this.serviceId,
  }) : super(key: key);

  final String placeId;
  final String serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Stream<DocumentSnapshot<DbPlace>>? placeStream;
  Stream<DocumentSnapshot<DbNearbyService>>? serviceStream;

  @override
  void initState() {
    final placeRef =
        FirebaseFirestore.instance.collection('places').doc(widget.placeId);
    placeStream = placeRef
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .snapshots();
    serviceStream = placeRef
        .collection('services')
        .doc(widget.serviceId)
        .withConverter<DbNearbyService>(
          fromFirestore: (snapshot, _) =>
              DbNearbyService.fromJson(snapshot.data()!),
          toFirestore: (service, _) => service.toJson(),
        )
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Service Details',
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
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot<DbPlace>>(
              stream: placeStream!,
              builder: (_, placeSnapshot) {
                if (placeSnapshot.hasError)
                  return const Center(child: Text('Something went wrong 😞'));
                if (placeSnapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                final placeData = placeSnapshot.data!.data()!;
                return StreamBuilder<DocumentSnapshot<DbNearbyService>>(
                    stream: serviceStream,
                    builder: (_, serviceSnapshot) {
                      if (serviceSnapshot.hasError)
                        return const Center(
                            child: Text('Something went wrong 😞'));
                      if (serviceSnapshot.connectionState ==
                          ConnectionState.waiting)
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      final serviceData = serviceSnapshot.data!.data()!;
                      return TabBarView(
                        children: [
                          ScheduleTabView(
                            placeData: placeData,
                            serviceId: widget.serviceId,
                            serviceData: serviceData,
                          ),
                          Container()
                        ],
                      );
                    });
              }),
        ),
      ),
    );
  }
}

class ScheduleTabView extends StatelessWidget {
  const ScheduleTabView({
    Key? key,
    required this.placeData,
    required this.serviceId,
    required this.serviceData,
  }) : super(key: key);

  final DbPlace placeData;
  final String serviceId;
  final DbNearbyService serviceData;

  @override
  Widget build(BuildContext context) {
    final policyStringBuilder = StringBuffer();
    policyStringBuilder
      ..write(
          'If you need to cancel or reschedule your appointment, be sure to ')
      ..write('do it more than ${serviceData.minLeadHours} hour(s) in advance.')
      ..write(' We will NOT allow you to cancel or reschedule less than ')
      ..write(
          '${serviceData.minLeadHours} hour(s) prior to your scheduled time slot.');

    return Scrollbar(
      isAlwaysShown: true,
      interactive: true,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.home_repair_service_outlined),
                        ),
                      ),
                      TextSpan(text: serviceData.serviceName),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.policy_outlined),
                        ),
                      ),
                      TextSpan(text: policyStringBuilder.toString()),
                    ],
                  ),
                ),
                const Divider(thickness: 1, height: 32),
                AppointmentScheduler(
                  validator: (value) async {
                    if (await timeSlotIsBooked(value))
                      return 'You already have an appointment at this time';
                  },
                  onTimeSlotSelect: (selectedDateTime) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBookingScreen(
                        serviceId: serviceId,
                        bookedService: serviceData,
                        selectedDateTime: selectedDateTime,
                      ),
                    ),
                  ),
                  minuteIncrements: serviceData.minuteIncrements!,
                  minLeadHours: serviceData.minLeadHours!,
                  maxLeadDays: serviceData.maxLeadDays!,
                  weeklySchedule: placeData.workingHours,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
