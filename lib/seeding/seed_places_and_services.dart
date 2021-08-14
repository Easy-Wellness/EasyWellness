import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:users/constants/specialties.dart';
import 'package:users/services/gmp_service/find_nearby_places.service.dart';

seedPlacesAndServices() async {
  final geo = Geoflutterfire();
  final db = FirebaseFirestore.instance;
  final places = await findNearbyPlaces();
  print('Seeding ${places.length} places and services for each...');
  await Future.wait(places.map((place) async {
    final clinicName = await _getFakeClinicName();
    GeoFirePoint location = geo.point(
      latitude: place.geometry.location.lat,
      longitude: place.geometry.location.lng,
    );
    final placeRef = db.collection('places').doc(place.placeId);
    final servicesRef = placeRef.collection('services');
    await placeRef.set({
      'name': clinicName,
      'geo_position': location.data,
      'address':
          '${place.vicinity}, ${place.plusCode.compoundCode.substring(8)}',
      'status': place.businessStatus,
    });
    await Future.wait(
      specialties.map(
        (specialty) => servicesRef.add({
          'rating': place.rating,
          'ratings_total': place.userRatingsTotal,
          'specialty': specialty,
          'service_name': specialty,
          'place_name': clinicName,
          'place_id': place.placeId,
          'address':
              '${place.vicinity}, ${place.plusCode.compoundCode.substring(8)}',
          'geo_position': location.data,
        }),
      ),
    );
  }));
  print('All done!');
}

Future<String> _getFakeClinicName() async {
  final fakerAPI = Uri.https(
    'fakercloud.com',
    '/schemas/property',
  );
  final response = await http.post(fakerAPI, body: {'name': 'Hospital'});
  if (response.statusCode == 200)
    return jsonDecode(response.body)['results'][0] as String;
  else
    throw HttpException(
      'Failed to find nearby places',
      uri: fakerAPI,
    );
}
