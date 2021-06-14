import 'package:json_annotation/json_annotation.dart';

part 'google_maps_geocode_result.g.dart';

@JsonSerializable()
class GoogleMapsGeocodeResult {
  GoogleMapsGeocodeResult({
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
  });

  @JsonKey(name: 'formatted_address')
  final String formattedAddress;

  @JsonKey(name: 'place_id')
  final String placeId;

  final Geometry geometry;

  factory GoogleMapsGeocodeResult.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsGeocodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsGeocodeResultToJson(this);
}

@JsonSerializable()
class Geometry {
  Geometry({
    required this.location,
    required this.locationType,
    required this.viewport,
    this.bounds,
  });

  @JsonKey(name: 'location_type')
  final String locationType;
  final GoogleMapsLocation location;
  final Bounds viewport;
  final Bounds? bounds;

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);

  Map<String, dynamic> toJson() => _$GeometryToJson(this);
}

@JsonSerializable()
class Bounds {
  Bounds({
    required this.northeast,
    required this.southwest,
  });

  final GoogleMapsLocation northeast;
  final GoogleMapsLocation southwest;

  factory Bounds.fromJson(Map<String, dynamic> json) => _$BoundsFromJson(json);

  Map<String, dynamic> toJson() => _$BoundsToJson(this);
}

@JsonSerializable()
class GoogleMapsLocation {
  GoogleMapsLocation({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  factory GoogleMapsLocation.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsLocationFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsLocationToJson(this);
}
