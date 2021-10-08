import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/widgets/booking_summary.dart';

class ApptListView extends StatelessWidget {
  const ApptListView({
    Key? key,
    required this.apptList,
    this.optionalBtnBuilder,
    required this.primaryBtnBuilder,
    required this.secondaryBtnBuilder,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbAppointment>> apptList;
  final OutlinedButton? Function(
      BuildContext, QueryDocumentSnapshot<DbAppointment>)? optionalBtnBuilder;
  final ElevatedButton Function(
      BuildContext, QueryDocumentSnapshot<DbAppointment>) primaryBtnBuilder;
  final OutlinedButton Function(
      BuildContext, QueryDocumentSnapshot<DbAppointment>) secondaryBtnBuilder;

  @override
  Widget build(BuildContext _) {
    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: apptList.length,
        itemBuilder: (ctx, idx) {
          final appt = apptList[idx].data();
          final optionalBtn = optionalBtnBuilder != null
              ? optionalBtnBuilder!(ctx, apptList[idx])
              : null;
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
                  if (optionalBtn != null) const Divider(thickness: 1),
                  if (optionalBtn != null) Center(child: optionalBtn),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      secondaryBtnBuilder(ctx, apptList[idx]),
                      const SizedBox(width: 8),
                      primaryBtnBuilder(ctx, apptList[idx]),
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
