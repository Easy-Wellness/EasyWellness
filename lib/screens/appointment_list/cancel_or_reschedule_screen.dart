import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/models/place/db_place.model.dart';
import 'package:users/utils/show_custom_snack_bar.dart';
import 'package:users/utils/time_slot_is_booked.dart';
import 'package:users/widgets/appointment_scheduler.dart';
import 'package:users/widgets/or_divider.dart';

class CancelOrRescheduleScreen extends StatelessWidget {
  CancelOrRescheduleScreen({
    Key? key,
    required this.apptId,
    required this.appointment,
  }) : super(key: key);

  final String apptId;
  final DbAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel or reschedule')),
      body: SafeArea(
        child: Scrollbar(
          isAlwaysShown: true,
          interactive: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Body(apptId: apptId, appointment: appointment),
            ),
          ),
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  Body({
    Key? key,
    required this.apptId,
    required this.appointment,
  }) : super(key: key);

  final String apptId;
  final DbAppointment appointment;
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Stream<DocumentSnapshot<DbPlace>>? placeStream;
  Stream<DocumentSnapshot<DbNearbyService>>? serviceStream;

  @override
  void initState() {
    final placeRef = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.appointment.placeId);
    placeStream = placeRef
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .snapshots();
    serviceStream = placeRef
        .collection('services')
        .doc(widget.appointment.serviceId)
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
    final effectiveAt = widget.appointment.effectiveAt.toDate();
    final friendlyDate = DateFormat.yMMMMEEEEd().format(effectiveAt);
    final friendlyTime = DateFormat.jm().format(effectiveAt);
    final apptRef = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.appointment.placeId)
        .collection('appointments')
        .doc(widget.apptId);
    return StreamBuilder<DocumentSnapshot<DbPlace>>(
      stream: placeStream!,
      builder: (context, placeSnapshot) {
        if (placeSnapshot.hasError)
          return const Center(child: Text('Something went wrong 😞'));
        if (placeSnapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator.adaptive());
        final placeData = placeSnapshot.data!.data()!;
        return StreamBuilder<DocumentSnapshot<DbNearbyService>>(
          stream: serviceStream!,
          builder: (context, serviceSnapshot) {
            if (serviceSnapshot.hasError)
              return const Center(child: Text('Something went wrong 😞'));
            if (serviceSnapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator.adaptive());
            final serviceData = serviceSnapshot.data!.data()!;
            final policyStringBuilder = StringBuffer();
            policyStringBuilder
              ..write(
                  'If you need to cancel or reschedule your appointment, be sure to ')
              ..write(
                  'do it more than ${serviceData.minLeadHours} hour(s) in advance.')
              ..write(
                  ' We will NOT allow you to cancel or reschedule less than ')
              ..write(
                  '${serviceData.minLeadHours} hour(s) prior to your scheduled time slot.');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(
                    serviceData.serviceName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    'At ${placeData.name}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Icon(Icons.event_outlined),
                        ),
                      ),
                      TextSpan(text: '$friendlyDate ($friendlyTime)'),
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
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Icon(Icons.policy_outlined),
                        ),
                      ),
                      TextSpan(text: policyStringBuilder.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.cancel_outlined),
                  label: Text('Cancel the appointment'),
                  style: OutlinedButton.styleFrom(primary: Colors.grey[800]),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Cancel appointment?'),
                      content: const Text('This action cannot be undone'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final cancellationPolicyIsFollowed = DateTime.now()
                                    .difference(effectiveAt)
                                    .inHours
                                    .abs() >=
                                serviceData.minLeadHours!;
                            Navigator.pop(context);
                            if (!cancellationPolicyIsFollowed)
                              return showCustomSnackBar(context,
                                  'You can only cancel your appointment ${serviceData.minLeadHours} hour(s) prior to your scheduled booking');
                            await apptRef.update({
                              'place_name': placeData.name,
                              'service_name': serviceData.serviceName,
                              'address': placeData.address,
                              'status': describeEnum(ApptStatus.canceled),
                            });
                            Navigator.pop(context);
                            showCustomSnackBar(context,
                                'Your appointment is successfully canceled');
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  ),
                ),
                const OrDivider(text: 'Or reschedule below'),
                AppointmentScheduler(
                  validator: (value) async {
                    final reschedulePolicyIsFollowed =
                        DateTime.now().difference(effectiveAt).inHours.abs() >=
                            serviceData.minLeadHours!;
                    if (!reschedulePolicyIsFollowed)
                      return 'You can only reschedule your appointment ${serviceData.minLeadHours} hour(s) prior to your scheduled booking';
                    if (await timeSlotIsBooked(value))
                      return 'You already have an appointment at this time';
                  },
                  onTimeSlotSelect: (selectedDateTime) => showDialog(
                    context: context,
                    builder: (_) {
                      final friendlyNewDate =
                          DateFormat.yMMMMEEEEd().format(selectedDateTime);
                      final friendlyNewTime =
                          DateFormat.jm().format(selectedDateTime);
                      return AlertDialog(
                        title: const Text('Reschedule appointment?'),
                        content: Text(
                            'If you click "yes", your appointment will be reschedule to "$friendlyNewDate ($friendlyNewTime)".'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await apptRef.update({
                                'place_name': placeData.name,
                                'service_name': serviceData.serviceName,
                                'address': placeData.address,
                                'effective_at':
                                    Timestamp.fromDate(selectedDateTime),
                              });
                              Navigator.pop(context);
                              Navigator.pop(context);
                              showCustomSnackBar(context,
                                  'Your appointment is successfully rescheduled');
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  ),
                  minuteIncrements: serviceData.minuteIncrements!,
                  minLeadHours: serviceData.minLeadHours!,
                  maxLeadDays: serviceData.maxLeadDays!,
                  weeklySchedule: placeData.workingHours,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
