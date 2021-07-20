import 'package:flutter/material.dart';
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
                      ..write(service.plusCode.compoundCode.substring(8))
                      ..toString();
                    return InkWell(
                      onTap: () {},
                      child: ListTile(
                        title: Text('$index ${service.name}'),
                        subtitle: Text(addressBuilder.toString()),
                        trailing: Text('${distance.round()} km'),
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
