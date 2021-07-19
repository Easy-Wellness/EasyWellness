// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmp_geocode_result.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleMapsGeocodeResult _$GoogleMapsGeocodeResultFromJson(
    Map<String, dynamic> json) {
  return GoogleMapsGeocodeResult(
    formattedAddress: json['formatted_address'] as String,
    geometry:
        GoogleMapsGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
    placeId: json['place_id'] as String,
  );
}

Map<String, dynamic> _$GoogleMapsGeocodeResultToJson(
        GoogleMapsGeocodeResult instance) =>
    <String, dynamic>{
      'formatted_address': instance.formattedAddress,
      'place_id': instance.placeId,
      'geometry': instance.geometry,
    };
