import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:users/constants/env.dart';
import 'package:users/models/location/gmp_nearby_place.model.dart';

/// Each search can return as many as 60 results, split across three pages.
/// [radius] defines the distance (in meters) within which to return place results
/// Setting [pageToken] will cause any other parameters to be ignored
Future<List<GoogleMapsNearbyPlace>> findNearbyPlaces({
  double latitude = 10.747754,
  double longitude = 106.636902,
  int radius = 15000,
  String type = 'convenience_store',
  String keyword = 'family',
  String? pageToken,
  List<GoogleMapsNearbyPlace> places = const [],
}) async {
  final nearbySearchAPI = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/nearbysearch/json',
    {
      'key': googleMapsApiKey,
      'location': '$latitude,$longitude',
      'radius': '$radius',
      'type': type,
      'keyword': keyword,
      'pagetoken': pageToken ?? '',
    },
  );
  final response = await http.get(nearbySearchAPI);
  if (response.statusCode == 200) {
    final jsonMap = jsonDecode(response.body);
    final nextPageToken = jsonMap['next_page_token'] as String?;
    final parsed = (jsonMap['results'] as List).cast<Map<String, dynamic>>();
    final currentPage = parsed
        .map<GoogleMapsNearbyPlace>(
            (json) => GoogleMapsNearbyPlace.fromJson(json))
        .toList();
    if (nextPageToken != null) {
      /// There is a delay between when a [next_page_token] is issued, and
      /// when it will become valid
      await Future.delayed(Duration(milliseconds: 1700));
      return await findNearbyPlaces(
          pageToken: nextPageToken, places: [...places, ...currentPage]);
    } else
      return [...places, ...currentPage];
  } else
    throw HttpException(
      'Failed to find nearby places',
      uri: nearbySearchAPI,
    );
}
