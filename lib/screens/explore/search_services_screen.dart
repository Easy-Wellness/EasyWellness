import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/screens/service_detail/service_detail_screen.dart';
import 'package:users/widgets/pick_location_screen.dart';

class SearchServicesScreen extends StatelessWidget {
  SearchServicesScreen({
    Key? key,
    required this.center,
    required this.specialty,
  }) : super(key: key);

  final GeoLocation center;
  final String specialty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Services')),
      body: SafeArea(
        child: Center(
          child: Material(
            child: StreamBuilder<DocSnapshotList>(
              stream: _servicesAroundLocationStream(center, specialty),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Text('Something went wrong');

                if (snapshot.connectionState == ConnectionState.waiting)
                  return const CircularProgressIndicator.adaptive();

                final nearbyServices = snapshot.data ?? [];
                if (nearbyServices.isEmpty)
                  return const Text('No nearby service is found');
                return Scrollbar(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailScreen(
                              serviceId: nearbyServices[index].id,
                              service: service,
                            ),
                          ),
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
                                    padding: const EdgeInsets.only(
                                        left: 2, bottom: 2),
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
              },
            ),
          ),
        ),
      ),
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
        field: 'geo_position',
        strictMode: true,
      );
}
