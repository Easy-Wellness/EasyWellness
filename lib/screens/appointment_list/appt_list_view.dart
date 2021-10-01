import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:users/widgets/booking_summary.dart';

import 'package:users/models/appointment/db_appointment.model.dart';

class ApptListView extends StatelessWidget {
  const ApptListView({
    Key? key,
    required this.apptList,
    required this.primaryBtnBuilder,
    this.secondaryBtnBuilder,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbAppointment>> apptList;
  final Widget Function(BuildContext, int) primaryBtnBuilder;
  final OutlinedButton Function(BuildContext, int)? secondaryBtnBuilder;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: apptList.length,
        itemBuilder: (ctx, idx) {
          final appt = apptList[idx].data();
          return Card(
            key: ValueKey(apptList[idx].id),
            elevation: 2,
            shape: ContinuousRectangleBorder(
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  BookingSummary(
                    serviceName: appt.serviceName,
                    placeName: appt.placeName,
                    address: appt.address,
                    dateTime: appt.effectiveAt.toDate(),
                  ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      if (secondaryBtnBuilder != null)
                        secondaryBtnBuilder!(context, idx),
                      const SizedBox(width: 8),
                      primaryBtnBuilder(context, idx),
                      const SizedBox(width: 8),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
      ),
    );
  }
}
