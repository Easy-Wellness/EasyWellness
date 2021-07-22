import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/models/location/geo_location.model.dart';
import 'package:users/models/location/gmp_nearby_place.model.dart';
import 'package:users/services/gmp_service/find_nearby_places.service.dart';

class SearchServicesScreen extends StatelessWidget {
  static String routeName = '/search_services';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Services'),
      ),
      body: SafeArea(child: Body()),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final centerLocation =
        ModalRoute.of(context)!.settings.arguments as GeoLocation;
    return Material(
      child: FutureBuilder(
          future: findNearbyPlaces(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return Scrollbar(
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: (snapshot.data as List).length,
                  separatorBuilder: (_, __) => Divider(thickness: 1),
                  itemBuilder: (context, index) {
                    final service =
                        (snapshot.data as List<GoogleMapsNearbyPlace>)[index];
                    final distance = Geolocator.distanceBetween(
                          centerLocation.latitule,
                          centerLocation.longitude,
                          service.geometry.location.lat,
                          service.geometry.location.lng,
                        ) /
                        1000;
                    final addressBuilder = StringBuffer()
                      ..write('${service.vicinity}, ')
                      ..write(service.plusCode.compoundCode.substring(8));
                    return InkWell(
                      onTap: () {},
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
                        title: Text('${service.name}'),
                        subtitle: Text(addressBuilder.toString()),
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
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
