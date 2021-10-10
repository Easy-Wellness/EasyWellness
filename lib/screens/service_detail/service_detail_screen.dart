import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/models/place/db_place.model.dart';
import 'package:users/screens/service_detail/information_tab_view.dart';

import 'schedule_tab_view.dart';

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
            'Service Detail',
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
                    stream: serviceStream!,
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
                          InformationTabView(
                            serviceId: widget.serviceId,
                            serviceData: serviceData,
                            placeData: placeData,
                          )
                        ],
                      );
                    });
              }),
        ),
      ),
    );
  }
}
