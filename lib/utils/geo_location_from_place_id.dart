import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:users/constants/misc.dart';
import 'package:users/models/geo_location.dart';
import 'package:users/models/google_maps_geocode_result.dart';

Future<GeoLocation> geoLocationFromPlaceId(String placeId) async {
  final geocodingAPI = Uri.https(
    'maps.googleapis.com',
    '/maps/api/geocode/json',
    {
      'key': googleMapsApiKey,
      'place_id': placeId,
    },
  );
  final response = await http.get(geocodingAPI);
  if (response.statusCode == 200) {
    final parsed = GoogleMapsGeocodeResult.fromJson(
        jsonDecode(response.body)['results'][0]);
    final geoCoords = parsed.geometry.location;
    return GeoLocation(
      latitule: geoCoords.lat,
      longitude: geoCoords.lng,
      address: parsed.formattedAddress,
    );
  } else
    throw HttpException(
      'Failed to find the location associated with this placeID',
      uri: geocodingAPI,
    );
}
