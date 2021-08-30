import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:users/models/appointment/db_appointment.model.dart';

/// Return true if the current user already has an appointment at the
/// [bookedDateTime], otherwise false
Future<bool> timeSlotIsBooked(DateTime bookedDateTime) async {
  final apptsRef = FirebaseFirestore.instance.collectionGroup('appointments');
  // Check if this account already has an appointment at this time
  final apptList = await apptsRef
      .where('account_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
      .where('effective_at', isEqualTo: Timestamp.fromDate(bookedDateTime))
      .get();
  return apptList.docs.isNotEmpty;
}
