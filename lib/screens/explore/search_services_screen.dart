import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:recase/recase.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/screens/service_detail/service_detail_screen.dart';
import 'package:users/utils/format_duration.dart';
import 'package:users/widgets/pick_location_screen.dart';

class SearchServicesScreen extends StatefulWidget {
  SearchServicesScreen({
    Key? key,
    required this.center,
    required this.specialty,
  }) : super(key: key);

  final GeoLocation center;
  final String specialty;

  @override
  State<SearchServicesScreen> createState() => _SearchServicesScreenState();
}

class _SearchServicesScreenState extends State<SearchServicesScreen> {
  Stream<DocSnapshotList>? serviceListStream;

  @override
  void initState() {
    serviceListStream =
        _servicesAroundLocationStream(widget.center, widget.specialty);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Services Around You')),
      body: SafeArea(
        child: Center(
          child: Material(
            child: StreamBuilder<DocSnapshotList>(
              stream: serviceListStream!,
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Text('Something went wrong');

                if (snapshot.connectionState == ConnectionState.waiting)
                  return const CircularProgressIndicator.adaptive();

                final nearbyServices = snapshot.data ?? [];
                if (nearbyServices.isEmpty)
                  return const Text('No nearby services are found');
                return Scrollbar(
                  child: ServiceListView(
                    serviceList: nearbyServices,
                    latitule: widget.center.latitule,
                    longitude: widget.center.longitude,
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

class ServiceListView extends StatelessWidget {
  const ServiceListView({
    Key? key,
    required this.serviceList,
    required this.latitule,
    required this.longitude,
  }) : super(key: key);

  final List<DocumentSnapshot<Map<String, dynamic>>> serviceList;
  final double latitule;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: serviceList.length,
      itemBuilder: (_, index) {
        final serviceData =
            DbNearbyService.fromJson(serviceList[index].data()!);
        final priceTag = serviceData.priceTag;
        String valueText = '';
        String typeText = describeEnum(priceTag.type).titleCase;
        switch (priceTag.type) {
          case PriceType.fixed:
          case PriceType.startingAt:
          case PriceType.hourly:
            valueText = '\$${priceTag.value}';
            typeText = ' ($typeText)';
            break;
          default:
        }
        final distance = Geolocator.distanceBetween(
              latitule,
              longitude,
              serviceData.geoPosition.geopoint.latitude,
              serviceData.geoPosition.geopoint.longitude,
            ) /
            1000;
        return Card(
          key: ValueKey(serviceList[index].id),
          elevation: 2,
          shape: ContinuousRectangleBorder(
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailScreen(
                  serviceId: serviceList[index].id,
                  placeId: serviceData.placeId,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    serviceData.serviceName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Row(
                    children: [
                      RatingBarIndicator(
                        rating: serviceData.rating,
                        itemCount: 5,
                        itemSize: 10,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(serviceData.rating.toString()),
                      const SizedBox(width: 16),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.near_me,
                                size: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            TextSpan(text: '${distance.toStringAsFixed(2)} km'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.timer_outlined),
                        ),
                        TextSpan(text: formatDuration(serviceData.duration)),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12, right: 4),
                          child: Icon(Icons.attach_money_outlined),
                        ),
                      ),
                      TextSpan(text: valueText + typeText),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12, right: 4),
                          child: Icon(Icons.place),
                        ),
                      ),
                      TextSpan(text: 'At ${serviceData.placeName}'),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12, right: 4),
                          child: Icon(Icons.map_outlined),
                        ),
                      ),
                      TextSpan(text: serviceData.address),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
