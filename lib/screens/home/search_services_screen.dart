import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/models/location/geo_location.model.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/screens/home/schedule_booking_screen.dart';

class SearchServicesScreen extends StatelessWidget {
  static String routeName = '/search_services';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Services')),
      body: SafeArea(child: Body()),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final center = args['center'] as GeoLocation;
    final specialty = args['specialty'] as String;
    return Material(
      child: StreamBuilder<DocSnapshotList>(
          stream: _servicesAroundLocationStream(center, specialty),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (snapshot.hasError) print(snapshot.error);

            if (snapshot.hasData) {
              final nearbyServices = snapshot.data ?? [];
              return Scrollbar(
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: nearbyServices.length,
                  separatorBuilder: (_, __) => Divider(thickness: 1),
                  itemBuilder: (context, index) {
                    final data = nearbyServices[index].data()!;
                    final service = DbNearbyService.fromJson(data);
                    final distance = Geolocator.distanceBetween(
                          center.latitule,
                          center.longitude,
                          service.geoPosition.geopoint.latitude,
                          service.geoPosition.geopoint.longitude,
                        ) /
                        1000;
                    return InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        BookingScreen.routeName,
                        arguments: {'service': service},
                      ),
                      child: ListTile(
                        leading: Column(
                          children: [
                            RatingBarIndicator(
                              rating: service.rating,
                              itemCount: 5,
                              itemSize: 10,
                              itemBuilder: (_, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('${service.rating}'),
                          ],
                        ),
                        title: Text(service.serviceName),
                        subtitle: Text(
                          '${service.address} (${service.placeName})',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        trailing: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText2,
                            children: [
                              TextSpan(
                                  text: '${distance.toStringAsFixed(2)} km'),
                              WidgetSpan(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 2, bottom: 2),
                                  child: Icon(Icons.near_me, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return Center(child: Text('No nearby service is found'));
          }),
    );
  }
}

typedef DocSnapshotList = List<DocumentSnapshot<Map<String, dynamic>>>;

/// Get real-time stream of docs that exist within X km around the [location]
Stream<DocSnapshotList> _servicesAroundLocationStream(
    GeoLocation location, String specialty) {
  final geo = Geoflutterfire();
  final center =
      geo.point(latitude: location.latitule, longitude: location.longitude);
  final db = FirebaseFirestore.instance;
  final queryRef =
      db.collectionGroup('services').where('specialty', isEqualTo: specialty);

  /// Optional parameter [strictMode = true] filters the docs
  /// strictly within the bound of given radius.
  ///
  /// Each docSnapshot.data() also contains distance calculated on the query.
  ///
  /// Note: filtering for [strictMode] happens on client side,
  /// hence filtering at larger radius is at the expense of
  /// making unnecessary document reads.
  return geo.collection(collectionRef: queryRef).within(
        center: center,
        radius: 9,
        field: 'geoPosition',
        strictMode: true,
      );
}
