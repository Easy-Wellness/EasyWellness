import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/widgets/booking_summary.dart';
import 'package:users/widgets/custom_bottom_nav_bar.dart';

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
      child: FutureBuilder(
        future: querySnapshot,
        builder: (_, AsyncSnapshot<QuerySnapshot<DbAppointment>> snapshot) {
          if (snapshot.hasError)
            return Text('Unable to show your appointments');
          if (snapshot.connectionState == ConnectionState.done) {
            final apptList = snapshot.data?.docs ?? [];
            if (apptList.isEmpty)
              return Text('You have no canceled appointments');
            return _ApptListView(
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
      child: FutureBuilder(
        future: querySnapshot,
        builder: (_, AsyncSnapshot<QuerySnapshot<DbAppointment>> snapshot) {
          if (snapshot.hasError)
            return Text('Unable to show your appointments');
          if (snapshot.connectionState == ConnectionState.done) {
            final apptList = snapshot.data?.docs ?? [];
            if (apptList.isEmpty) return Text('No results found');
            return _ApptListView(
              apptList: apptList,
              primaryBtnBuilder: (_, index) => ElevatedButton.icon(
                icon: const Icon(Icons.reviews_outlined),
                label: const Text('Rate'),
                onPressed: () {},
              ),
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

class UpcomingTabView extends StatefulWidget {
  const UpcomingTabView({Key? key}) : super(key: key);

  @override
  _UpcomingTabViewState createState() => _UpcomingTabViewState();
}

class _UpcomingTabViewState extends State<UpcomingTabView> {
  final querySnapshot = _apptsRef
      .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
      .where('effective_at', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .orderBy('effective_at')
      .get();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: querySnapshot,
        builder: (_, AsyncSnapshot<QuerySnapshot<DbAppointment>> snapshot) {
          if (snapshot.hasError)
            return Text('Unable to show your appointments');
          if (snapshot.connectionState == ConnectionState.done) {
            final apptList = snapshot.data?.docs ?? [];
            if (apptList.isEmpty)
              return Text('You have no upcoming appointments');
            return _ApptListView(
              apptList: apptList,
              primaryBtnBuilder: (_, index) => ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat'),
                onPressed: () {},
              ),
              secondaryBtnBuilder: (_, idx) => OutlinedButton(
                child: const Text('Cancel or reschedule'),
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

class _ApptListView extends StatelessWidget {
  const _ApptListView({
    Key? key,
    required this.apptList,
    required this.primaryBtnBuilder,
    this.secondaryBtnBuilder,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbAppointment>> apptList;
  final ElevatedButton Function(BuildContext, int) primaryBtnBuilder;
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
            key: ValueKey<String>(apptList[idx].id),
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
