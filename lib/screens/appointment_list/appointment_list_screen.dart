import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/screens/appointment_list/appt_list_view.dart';
import 'package:users/screens/appointment_list/cancel_or_reschedule_screen.dart';
import 'package:users/screens/appointment_list/collect_review_and_rating_screen.dart';
import 'package:users/widgets/custom_bottom_nav_bar.dart';
import 'package:users/widgets/widget_with_toggleable_child.dart';

final _apptsRef = FirebaseFirestore.instance
    .collectionGroup('appointments')
    .where('account_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    .withConverter<DbAppointment>(
      fromFirestore: (snapshot, _) => DbAppointment.fromJson(snapshot.data()!),
      toFirestore: (appt, _) => appt.toJson(),
    );

class AppointmentListScreen extends StatelessWidget {
  static const String routeName = '/appointment_list';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your bookings'),
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 60),
            child: TabBar(
              unselectedLabelColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor,
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
        ),
        body: TabBarView(
            children: [UpcomingTabView(), PastTabView(), CanceledTabView()]),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class UpcomingTabView extends StatefulWidget {
  const UpcomingTabView({Key? key}) : super(key: key);

  @override
  _UpcomingTabViewState createState() => _UpcomingTabViewState();
}

class _UpcomingTabViewState extends State<UpcomingTabView> {
  final queryStream = _apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
      .where('effective_at', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .orderBy('effective_at')
      .snapshots();
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
          if (apptList.isEmpty)
            return Text('You have no upcoming appointments');
          return ApptListView(
            apptList: apptList,
            primaryBtnBuilder: (_, index) => ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
              onPressed: () {},
            ),
            secondaryBtnBuilder: (_, idx) => OutlinedButton(
              child: const Text('Cancel or reschedule'),
              onPressed: () => Navigator.pushNamed(
                context,
                CancelOrRescheduleScreen.routeName,
                arguments: {
                  'apptId': apptList[idx].id,
                  'appointment': apptList[idx].data(),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class PastTabView extends StatefulWidget {
  const PastTabView({Key? key}) : super(key: key);

  @override
  _PastTabViewState createState() => _PastTabViewState();
}

class _PastTabViewState extends State<PastTabView> {
  final querySnapshot = _apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
      .where('effective_at',
          isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
      .orderBy('effective_at', descending: true)
      .get();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<QuerySnapshot<DbAppointment>>(
        future: querySnapshot,
        builder: (_, snapshot) {
          if (snapshot.hasError)
            return Text('Unable to show your appointments');
          if (snapshot.connectionState == ConnectionState.done) {
            final apptList = snapshot.data?.docs ?? [];
            if (apptList.isEmpty) return Text('No results found');
            return ApptListView(
              apptList: apptList,
              primaryBtnBuilder: (_, index) {
                final appt = apptList[index].data();
                if (!appt.isReviewed)
                  return WidgetWithToggleableChild(
                    builder: (widgetState) => ElevatedButton.icon(
                      icon: const Icon(Icons.reviews_outlined),
                      label: const Text('Rate'),
                      onPressed: () async {
                        /// If result is [true], it means the rating and
                        /// review is submitted
                        final result = await Navigator.pushNamed(
                          context,
                          CollectReviewAndRatingScreen.routeName,
                          arguments: {
                            'apptId': apptList[index].id,
                            'serviceId': appt.serviceId,
                            'serviceName': appt.serviceName,
                            'placeId': appt.placeId,
                            'placeName': appt.placeName,
                          },
                        );
                        if (result == true)
                          return widgetState.toggleShow(false);
                      },
                    ),
                  );
                return Container();
              },
              secondaryBtnBuilder: (_, idx) => OutlinedButton(
                child: const Text('Book again'),
                onPressed: () {},
              ),
            );
          }
          return const CircularProgressIndicator.adaptive();
        },
      ),
    );
  }
}

class CanceledTabView extends StatefulWidget {
  const CanceledTabView({Key? key}) : super(key: key);

  @override
  _CanceledTabViewState createState() => _CanceledTabViewState();
}

class _CanceledTabViewState extends State<CanceledTabView> {
  final querySnapshot = _apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.canceled))
      .orderBy('effective_at', descending: true)
      .get();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<QuerySnapshot<DbAppointment>>(
        future: querySnapshot,
        builder: (_, snapshot) {
          if (snapshot.hasError)
            return Text('Unable to show your appointments');
          if (snapshot.connectionState == ConnectionState.done) {
            final apptList = snapshot.data?.docs ?? [];
            if (apptList.isEmpty)
              return Text('You have no canceled appointments');
            return ApptListView(
              apptList: apptList,
              primaryBtnBuilder: (_, index) => ElevatedButton(
                child: const Text('Book again'),
                onPressed: () {},
              ),
            );
          }
          return const CircularProgressIndicator.adaptive();
        },
      ),
    );
  }
}
