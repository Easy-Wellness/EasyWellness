// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmp_geometry.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleMapsGeometry _$GoogleMapsGeometryFromJson(Map<String, dynamic> json) {
  return GoogleMapsGeometry(
    location:
        GoogleMapsLocation.fromJson(json['location'] as Map<String, dynamic>),
    viewport: Bounds.fromJson(json['viewport'] as Map<String, dynamic>),
    locationType: json['location_type'] as String?,
    bounds: json['bounds'] == null
        ? null
        : Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GoogleMapsGeometryToJson(GoogleMapsGeometry instance) =>
    <String, dynamic>{
      'location': instance.location,
      'viewport': instance.viewport,
      'bounds': instance.bounds,
      'location_type': instance.locationType,
    };

Bounds _$BoundsFromJson(Map<String, dynamic> json) {
  return Bounds(
    northeast:
        GoogleMapsLocation.fromJson(json['northeast'] as Map<String, dynamic>),
    southwest:
        GoogleMapsLocation.fromJson(json['southwest'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BoundsToJson(Bounds instance) => <String, dynamic>{
      'northeast': instance.northeast,
      'southwest': instance.southwest,
    };

GoogleMapsLocation _$GoogleMapsLocationFromJson(Map<String, dynamic> json) {
  return GoogleMapsLocation(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );
}

Map<String, dynamic> _$GoogleMapsLocationToJson(GoogleMapsLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
