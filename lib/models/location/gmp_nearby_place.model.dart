import 'package:json_annotation/json_annotation.dart';

import 'package:users/models/location/gmp_geometry.model.dart';

part 'gmp_nearby_place.model.g.dart';

/// Nearby Search response: https://developers.google.com/maps/documentation/places/web-service/search#nearby-search-and-text-search-responses
@JsonSerializable()
class GoogleMapsNearbyPlace {
  GoogleMapsNearbyPlace({
    required this.businessStatus,
    required this.geometry,
    required this.name,
    required this.placeId,
    required this.plusCode,
    required this.rating,
    required this.userRatingsTotal,
    required this.vicinity,
  });

  final String name;
  final int rating;
  final String vicinity;
  final GoogleMapsGeometry geometry;

  @JsonKey(name: 'place_id')
  final String placeId;

  @JsonKey(name: 'business_status')
  final String businessStatus;

  @JsonKey(name: 'user_ratings_total')
  final int userRatingsTotal;

  @JsonKey(name: 'plus_code')
  final PlusCode plusCode;

  factory GoogleMapsNearbyPlace.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsNearbyPlaceFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsNearbyPlaceToJson(this);
}

@JsonSerializable()
class PlusCode {
  PlusCode({
    required this.compoundCode,
    required this.globalCode,
  });

  @JsonKey(name: 'compound_code')
  final String compoundCode;

  @JsonKey(name: 'global_code')
  final String globalCode;

  factory PlusCode.fromJson(Map<String, dynamic> json) =>
      _$PlusCodeFromJson(json);

  Map<String, dynamic> toJson() =>_$PlusCodeToJson(this);
}
