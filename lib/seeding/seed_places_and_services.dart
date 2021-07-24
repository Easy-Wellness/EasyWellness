import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
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
    await placeRef.set({
      'name': clinicName,
      'geoPosition': location.data,
      'address':
          '${place.vicinity}, ${place.plusCode.compoundCode.substring(8)}',
      'status': place.businessStatus,
    });
    await Future.wait(
        specialties.map((specialty) => placeRef.collection('services').add({
              'serviceName': specialty,
              'placeName': clinicName,
              'placeId': place.placeId,
              'geoPosition': location.data,
              'address':
                  '${place.vicinity}, ${place.plusCode.compoundCode.substring(8)}',
              'specialty': specialty,
              'rating': place.rating,
              'ratingsTotal': place.userRatingsTotal,
            })));
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
