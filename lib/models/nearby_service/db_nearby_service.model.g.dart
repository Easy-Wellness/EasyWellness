// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_nearby_service.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbNearbyService _$DbNearbyServiceFromJson(Map<String, dynamic> json) {
  return DbNearbyService(
    rating: (json['rating'] as num).toDouble(),
    ratingsTotal: json['ratings_total'] as int,
    specialty: json['specialty'] as String,
    serviceName: json['service_name'] as String? ?? '',
    placeName: json['place_name'] as String? ?? '',
    placeId: json['place_id'] as String? ?? '',
    address: json['address'] as String,
    geoPosition:
        GeoPosition.fromJson(json['geo_position'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DbNearbyServiceToJson(DbNearbyService instance) =>
    <String, dynamic>{
      'specialty': instance.specialty,
      'address': instance.address,
      'rating': instance.rating,
      'ratings_total': instance.ratingsTotal,
      'service_name': instance.serviceName,
      'geo_position': instance.geoPosition,
      'place_id': instance.placeId,
      'place_name': instance.placeName,
    };

GeoPosition _$GeoPositionFromJson(Map<String, dynamic> json) {
  return GeoPosition(
    geohash: json['geohash'] as String,
    geopoint: GeoPosition._fromJsonGeoPoint(json['geopoint'] as GeoPoint),
  );
}

Map<String, dynamic> _$GeoPositionToJson(GeoPosition instance) =>
    <String, dynamic>{
      'geohash': instance.geohash,
      'geopoint': GeoPosition._toJsonGeoPoint(instance.geopoint),
    };
