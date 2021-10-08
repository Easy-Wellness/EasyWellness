import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/screens/appointment_list/appt_list_view.dart';
import 'package:users/screens/appointment_list/cancel_or_reschedule_screen.dart';
import 'package:users/screens/service_detail/service_detail_screen.dart';
import 'package:users/widgets/custom_bottom_nav_bar.dart';

import 'collect_review_and_rating_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  static const String routeName = '/appointment_list';

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final apptsRef = FirebaseFirestore.instance
      .collectionGroup('appointments')
      .where('account_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .withConverter<DbAppointment>(
        fromFirestore: (snapshot, _) =>
            DbAppointment.fromJson(snapshot.data()!),
        toFirestore: (appt, _) => appt.toJson(),
      );
  late final Stream<QuerySnapshot<DbAppointment>> upcomingStream = apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
      .where('effective_at', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .orderBy('effective_at')
      .snapshots();
  late final Stream<QuerySnapshot<DbAppointment>> pastStream = apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
      .where('effective_at',
          isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
      .orderBy('effective_at', descending: true)
      .snapshots();
  late final Stream<QuerySnapshot<DbAppointment>> canceledStream = apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.canceled))
      .orderBy('effective_at', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            unselectedLabelColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Column(
                children: [
                  Icon(Icons.upcoming_outlined),
                  Tab(text: 'Upcoming'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.stars_outlined),
                  Tab(text: 'To rate'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.event_busy_outlined),
                  Tab(text: 'Canceled'),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AppointmentListTabView(
              queryStream: upcomingStream,
              secondaryBtnBuilder: (_, apptSnapshot) => OutlinedButton(
                child: const Text('Cancel or reschedule'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CancelOrRescheduleScreen(
                      apptId: apptSnapshot.id,
                      appointment: apptSnapshot.data(),
                    ),
                  ),
                ),
              ),
            ),
            AppointmentListTabView(
              queryStream: pastStream,
              optionalBtnBuilder: (_, apptSnapshot) {
                final apptData = apptSnapshot.data();
                if (!apptData.isReviewed)
                  return OutlinedButton.icon(
                    icon: const Icon(Icons.reviews_outlined),
                    label: const Text('Rate this service'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectReviewAndRatingScreen(
                          apptId: apptSnapshot.id,
                          serviceId: apptData.serviceId,
                          serviceName: apptData.serviceName,
                          placeId: apptData.placeId,
                          placeName: apptData.placeName,
                        ),
                      ),
                    ),
                  );
              },
              secondaryBtnBuilder: (_, apptSnapshot) => OutlinedButton(
                child: const Text('Book again'),
                onPressed: () {
                  final apptData = apptSnapshot.data();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(
                        serviceId: apptData.serviceId,
                        placeId: apptData.placeId,
                      ),
                    ),
                  );
                },
              ),
            ),
            AppointmentListTabView(
              queryStream: canceledStream,
              secondaryBtnBuilder: (_, apptSnapshot) => OutlinedButton(
                child: const Text('Book again'),
                onPressed: () {
                  final apptData = apptSnapshot.data();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(
                        serviceId: apptData.serviceId,
                        placeId: apptData.placeId,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class AppointmentListTabView extends StatelessWidget {
  const AppointmentListTabView({
    Key? key,
    required this.queryStream,
    this.optionalBtnBuilder,
    required this.secondaryBtnBuilder,
  }) : super(key: key);

  final Stream<QuerySnapshot<DbAppointment>> queryStream;
  final OutlinedButton? Function(
      BuildContext, QueryDocumentSnapshot<DbAppointment>)? optionalBtnBuilder;
  final OutlinedButton Function(
      BuildContext, QueryDocumentSnapshot<DbAppointment>) secondaryBtnBuilder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot<DbAppointment>>(
        stream: queryStream,
        builder: (_, snapshot) {
          if (snapshot.hasError) return const Text('Something went wrong');

          if (snapshot.connectionState == ConnectionState.waiting)
            return const CircularProgressIndicator.adaptive();

          final apptList = snapshot.data?.docs ?? [];
          if (apptList.isEmpty) return Text('No appointments found');
          return ApptListView(
            apptList: apptList,
            optionalBtnBuilder: optionalBtnBuilder,
            primaryBtnBuilder: (_, apptSnapshot) => ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
              onPressed: () {},
            ),
            secondaryBtnBuilder: secondaryBtnBuilder,
          );
        },
      ),
    );
  }
}
