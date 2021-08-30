import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/widgets/appointment_scheduler.dart';
import 'package:users/widgets/or_divider.dart';
import 'package:users/widgets/show_custom_snack_bar.dart';

class CancelOrRescheduleScreen extends StatelessWidget {
  static const String routeName = '/cancel_and_reschedule_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel or reschedule')),
      body: SafeArea(child: Body()),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final apptId = args['apptId'] as String;
    final appt = args['appointment'] as DbAppointment;
    final effectiveAt = appt.effectiveAt.toDate();
    final friendlyDate = DateFormat.yMMMMEEEEd().format(effectiveAt);
    final friendlyTime = DateFormat.jm().format(effectiveAt);
    final apptRef = FirebaseFirestore.instance
        .collection('places')
        .doc(appt.placeId)
        .collection('appointments')
        .doc(apptId);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                appt.serviceName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Text(appt.placeName),
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
            OutlinedButton.icon(
              icon: Icon(Icons.cancel_outlined),
              label: Text('Cancel the appointment'),
              style: OutlinedButton.styleFrom(primary: Colors.grey[800]),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cancel appointment'),
                  content: Text('This action cannot be undone'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await apptRef.update(
                            {'status': describeEnum(ApptStatus.canceled)});
                        Navigator.pop(context);
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
            AppointmentScheduler(onTimeSlotSelect: (selectedDateTime) async {
              await apptRef.update(
                  {'effective_at': Timestamp.fromDate(selectedDateTime)});
              Navigator.pop(context);
              showCustomSnackBar(
                  context, 'Your appointment is successfully rescheduled');
            }),
          ],
        ),
      ),
    );
  }
}
