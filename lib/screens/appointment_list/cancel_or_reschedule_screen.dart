import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/widgets/appointment_scheduler.dart';
import 'package:users/widgets/or_divider.dart';

class CancelOrRescheduleScreen extends StatelessWidget {
  static const String routeName = '/cancel_and_reschedule_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel or reschedule')),
      body: Body(),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(appt.placeId)
                            .collection('appointments')
                            .doc(apptId)
                            .update(
                                {'status': describeEnum(ApptStatus.canceled)});
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Your appointment is successfully canceled'),
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ),
              ),
            ),
            const OrDivider(text: 'Or reschedule below'),
            AppointmentScheduler(onTimeSlotSelect: (selectedDateTime) {}),
          ],
        ),
      ),
    );
  }
}
